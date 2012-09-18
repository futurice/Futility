//
// Colors.h
//
/*
The MIT License

Copyright (c) 2011-2012 Ali Rantakari

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#define COLOR_RGBA(r,g,b,a) [UIColor colorWithRed:(r) green:(g) blue:(b) alpha:(a)]
#define COLOR_RGB(r,g,b)    COLOR_RGBA(r,g,b,1.0)
#define COLOR_HSBA(h,s,b,a) [UIColor colorWithHue:(h) saturation:(s) brightness:(b) alpha:(a)]
#define COLOR_HSB(h,s,b)    COLOR_HSBA(h,s,b,1.0)

#define COLOR_HEX(__hex)      COLOR_RGB(((__hex >> 16) & 0xFF)/255.0f, ((__hex >> 8) & 0xFF)/255.0f, (__hex & 0xFF)/255.0f)
#define COLOR_HEX_A(__hex,a)  COLOR_RGBA(((__hex >> 16) & 0xFF)/255.0f, ((__hex >> 8) & 0xFF)/255.0f, (__hex & 0xFF)/255.0f, (a))
