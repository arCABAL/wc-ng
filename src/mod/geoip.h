/***********************************************************************
 *  WC-NG - Cube 2: Sauerbraten Modification                           *
 *  Copyright (C) 2014, 2015 by Thomas Poechtrager                     *
 *  t.poechtrager@gmail.com                                            *
 *                                                                     *
 *  This program is free software; you can redistribute it and/or      *
 *  modify it under the terms of the GNU General Public License        *
 *  as published by the Free Software Foundation; either version 2     *
 *  of the License, or (at your option) any later version.             *
 *                                                                     *
 *  This program is distributed in the hope that it will be useful,    *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *
 *  GNU General Public License for more details.                       *
 *                                                                     *
 *  You should have received a copy of the GNU General Public License  *
 *  along with this program; if not, write to the Free Software        *
 *  Foundation, Inc.,                                                  *
 *  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.      *
 ***********************************************************************/

namespace mod {
namespace extinfo { struct playerv2; }
namespace geoip
{
    bool loaddatabase(const char *db);
    void closedatabase();
    const char *country(const char *ip);
    const char *country(uint ip);
    const char *countrycode(const char *ip);
    const char *countrycode(uint ip);
    const char *staticcountry(size_t index);
    const char *staticcountrycode(const char *countrycode, size_t *index);
    void lookupcountry(const extinfo::playerv2 *ep, const char *&country, const char *&countrycode);
    void startup();
    void shutdown();
} //namespace geoip
} //namespace mod
