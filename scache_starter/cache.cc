/* 
 * File: cache.ccc
 * Author: Trip Master
 * --------------------
 * This is the implementation file for the SCache class.
 * SCache is a very simple software model of a 1-level MSI
 * cache. The aim of the assignment is for students to encode
 * their understanding of simple MSI cache coherence.
 * 
 * This assignment was written for CS80E.
 * First drafted: 8/10/23
*/

#include "cache.hh"
#include <iostream>
#include "softram.hh"
#include <cassert>
#include <cmath>

using namespace std;

/* Static redeclarations. */
size_t SCache::CORE_CNTR = 0;
vector<SCache *> SCache::_bus = {};
SoftRam SCache::_ram;

SCache::SCache( const size_t num_lines ) : _CORE_ID(CORE_CNTR++) {
    
    /* Fail loudly if the line size is not a power of 2. */
    if (LINE_SZ % 2) {
        cout << "ERROR: Line_SZ is not a power of 2." << endl;
        assert(0);
    }
    _cache.resize(num_lines);
    // Initialize the cache lines and add this cache to the _bus vector
    for (int i = 0; i < num_lines; i++) {
        _cache[i].state = Line_State::INVALID;
        _cache[i].owner = 0; // Set the owner to a default value
    }
    _bus.push_back(this);
}
/*destructor*/
SCache::~SCache() {
    auto it = std::find(_bus.begin(), _bus.end(), this);
    if (it != _bus.end()) 
        _bus.erase(it);
}


void SCache::put( void* data ) {
    cout << "put call" <<endl;
    addr_t addr = (addr_t)addr_aligned(data);
    addr_t tag = (addr_t)addr_to_tag(addr);
    unsigned long index = addr_to_index(addr);
    
    Line& cacheLine = _cache[index];
    addr_t newtag = (addr_t)addr_to_tag(cacheLine.addr);

    if (cacheLine.state == Line_State::SHARED || cacheLine.state == Line_State::INVALID || newtag != tag) {
        // The cache line is not in the cache or the tags don't match
        // Request the line from other caches or RAM using busRdX
        cout <<"putting addr: " << addr << endl;
        bus_rdX(addr);

        // The line should now be in MODIFIED state
        // Set the new data and tag in the cache line
        cacheLine.state = Line_State::MODIFIED;
        cacheLine.addr = addr;
        memcpy(cacheLine.data, data, LINE_SZ);

        // Notify other caches to invalidate their copy of this line

        for (Line& othersharers: _cache) {
            if (othersharers.state == Line_State::SHARED){
                othersharers.state = Line_State::INVALID;
                }
            }
    }
    else {
        bus_rdX(addr);
        cacheLine.addr = addr;
        memcpy(cacheLine.data, data, LINE_SZ);
    }

}

bool SCache::get(addr_t addr, void* buf) {
    addr = (addr_t)addr_aligned(addr); // Byte-align address.
    addr_t tag = (addr_t)addr_to_tag(addr);
    unsigned long index = addr_to_index(addr);


    // Find the cache line for the given address
    Line& cacheLine = _cache[index];
    addr_t newtag = (addr_t)addr_to_tag(cacheLine.addr);

    if (cacheLine.state == Line_State::INVALID || newtag != tag) {

        bool det = bus_rd(addr);
        if (det == false)
            return false;
        cacheLine.state = Line_State::SHARED;
        cacheLine.addr = addr;

        memcpy(buf, cacheLine.data, LINE_SZ);
        return true;
    }
    else {
        bus_rd(addr);
        cacheLine.addr = addr;
        memcpy(buf, cacheLine.data, LINE_SZ);
    }
    return true;
}

bool SCache::bus_rd(addr_t addr) {
    addr_t tag = (addr_t)addr_to_tag(addr);
    unsigned long index = addr_to_index(addr);

    // Find the cache line for the given address
    Line& cacheLine = _cache[index];

    for (SCache *otherCache : _bus) {
        if (otherCache != this) {
            Line &otherLine = otherCache->_cache[index];
            addr_t newtag = (addr_t)addr_to_tag(otherLine.addr);
            if (newtag == tag) {
                if (otherLine.state == Line_State::MODIFIED)
                {
                    otherLine.state = Line_State::SHARED;
                    _ram.flush(otherLine.data, otherLine.addr);
                }
                else if (otherLine.state == Line_State::SHARED) {
                    memcpy(cacheLine.data, otherLine.data, LINE_SZ);
                }
                else {
                    bool success = _ram.read(otherLine.addr, otherLine.data);
                    if (success) {
                        otherLine.state = Line_State::SHARED;
                        memcpy(cacheLine.data, otherLine.data, LINE_SZ);
                    }
                    else
                        return false;
            }
        }
    }
    }
    return true;
}
void SCache::bus_rdX(addr_t addr) {
    addr_t tag = (addr_t)addr_to_tag(addr);
    unsigned long index = addr_to_index(addr);

    Line& cacheLine = _cache[index];
    for (SCache *otherCache : _bus) {
        cout << "peeking at other cache" << endl;
        if (otherCache != this) {
            Line &otherLine = otherCache->_cache[index];
            cout << "their tag: " << (addr_t)addr_to_tag(otherLine.addr) << endl;
            cout << "our tag:" << tag << endl;
            cout << "their address : " << otherLine.addr << endl;
            addr_t newtag = (addr_t)addr_to_tag(otherLine.addr);
            if (newtag == tag){
                if (otherLine.state == Line_State::MODIFIED) {
                    cout << "collision!" << endl;
                    otherLine.state = Line_State::INVALID;
                    _ram.flush(otherLine.data, otherLine.addr);
                }
                else if (otherLine.state == Line_State::SHARED){
                    cout<< "entered" <<endl;
                    for (Line &allLines: otherCache->_cache){
                        if (allLines.state == Line_State::SHARED)
                        {
                            cout <<"e2"<<endl;
                            allLines.state = Line_State::INVALID;
                            _ram.flush(allLines.data, allLines.addr);
                        }
                    }
                }
                else {
                    bool success = _ram.read(otherLine.addr, otherLine.data);
                    if (success) {
                        memcpy(cacheLine.data, otherLine.data, LINE_SZ);
                        cacheLine.state = Line_State::SHARED;
                        cacheLine.addr = otherLine.addr;
                    }
                    else {
                        cacheLine.state = Line_State::SHARED;
                        cacheLine.addr = otherLine.addr;
                    }

                }
            }
        }
    }

}

/* Provided helper for debugging. Pls ignore. */
vector<Line> SCache::get_debug_info() {
    return this->_cache;
}

/* 
 * Provided Address-extracting helper functions. Please
 * make use of them, but do not modify them! 
 *
 * NOTE: that ulong casting needs to be used instead of addr_t
 * to satisfy the compiler.
*/
unsigned long SCache::addr_to_index(addr_t address) {    
    // Mask off all but the lower 16 bits. Shift out the line size bits.
    return ((unsigned long)address & 0x00000000FFFF) >> LINE_SZ_BITS;
}

unsigned long SCache::addr_to_tag(addr_t address) {
    // All bits except for the lower 16 bits.
    return ((unsigned long)address & 0xFFFFFFFF0000) >> 16;
}

unsigned long SCache::addr_aligned(addr_t address) {
    // Zero out the lower LINE_SZ_BITS bits.
    return (((unsigned long)address >> LINE_SZ_BITS) << LINE_SZ_BITS);
} 