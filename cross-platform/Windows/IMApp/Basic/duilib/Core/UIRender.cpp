#include "StdAfx.h"

#define STB_IMAGE_IMPLEMENTATION
#include "..\Utils\stb_image.h"

#ifdef USE_XIMAGE_EFFECT
#    include "../../3rd/CxImage/ximage.h"
#    include "../../3rd/CxImage/ximage.cpp"
#    include "../../3rd/CxImage/ximaenc.cpp"
#    include "../../3rd/CxImage/ximagif.cpp"
#    include "../../3rd/CxImage/ximainfo.cpp"
#    include "../../3rd/CxImage/ximalpha.cpp"
#    include "../../3rd/CxImage/ximapal.cpp"
#    include "../../3rd/CxImage/ximatran.cpp"
#    include "../../3rd/CxImage/ximawnd.cpp"
#    include "../../3rd/CxImage/xmemfile.cpp"
#endif

///////////////////////////////////////////////////////////////////////////////////////
namespace DuiLib {
    static int g_iFontID = MAX_FONT_ID;

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CRenderClip::~CRenderClip()
    {
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
        ASSERT(::GetObjectType(hRgn)==OBJ_REGION);
        ASSERT(::GetObjectType(hOldRgn)==OBJ_REGION);
        ::SelectClipRgn(hDC, hOldRgn);
        ::DeleteObject(hOldRgn);
        ::DeleteObject(hRgn);
    }

    void CRenderClip::GenerateClip(HDC hDC, RECT rc, CRenderClip& clip)
    {
        RECT rcClip = { 0 };
        ::GetClipBox(hDC, &rcClip);
        clip.hOldRgn = ::CreateRectRgnIndirect(&rcClip);
        clip.hRgn = ::CreateRectRgnIndirect(&rc);
        ::ExtSelectClipRgn(hDC, clip.hRgn, RGN_AND);
        clip.hDC = hDC;
        clip.rcItem = rc;
    }

    void CRenderClip::GenerateRoundClip(HDC hDC, RECT rc, RECT rcItem, int width, int height, CRenderClip& clip)
    {
        RECT rcClip = { 0 };
        ::GetClipBox(hDC, &rcClip);
        clip.hOldRgn = ::CreateRectRgnIndirect(&rcClip);
        clip.hRgn = ::CreateRectRgnIndirect(&rc);
        HRGN hRgnItem = ::CreateRoundRectRgn(rcItem.left, rcItem.top, rcItem.right + 1, rcItem.bottom + 1, width, height);
        ::CombineRgn(clip.hRgn, clip.hRgn, hRgnItem, RGN_AND);
        ::ExtSelectClipRgn(hDC, clip.hRgn, RGN_AND);
        clip.hDC = hDC;
        clip.rcItem = rc;
        ::DeleteObject(hRgnItem);
    }

    void CRenderClip::UseOldClipBegin(HDC hDC, CRenderClip& clip)
    {
        ::SelectClipRgn(hDC, clip.hOldRgn);
    }

    void CRenderClip::UseOldClipEnd(HDC hDC, CRenderClip& clip)
    {
        ::SelectClipRgn(hDC, clip.hRgn);
    }

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    static const float OneThird = 1.0f / 3;

    static void RGBtoHSL(DWORD ARGB, float* H, float* S, float* L) {
        const float
            R = (float)GetRValue(ARGB),
            G = (float)GetGValue(ARGB),
            B = (float)GetBValue(ARGB),
            nR = (R<0?0:(R>255?255:R))/255,
            nG = (G<0?0:(G>255?255:G))/255,
            nB = (B<0?0:(B>255?255:B))/255,
            m = min(min(nR,nG),nB),
            M = max(max(nR,nG),nB);
        *L = (m + M)/2;
        if (M==m) *H = *S = 0;
        else {
            const float
                f = (nR==m)?(nG-nB):((nG==m)?(nB-nR):(nR-nG)),
                i = (nR==m)?3.0f:((nG==m)?5.0f:1.0f);
            *H = (i-f/(M-m));
            if (*H>=6) *H-=6;
            *H*=60;
            *S = (2*(*L)<=1)?((M-m)/(M+m)):((M-m)/(2-M-m));
        }
    }

    static void HSLtoRGB(DWORD* ARGB, float H, float S, float L) {
        const float
            q = 2*L<1?L*(1+S):(L+S-L*S),
            p = 2*L-q,
            h = H/360,
            tr = h + OneThird,
            tg = h,
            tb = h - OneThird,
            ntr = tr<0?tr+1:(tr>1?tr-1:tr),
            ntg = tg<0?tg+1:(tg>1?tg-1:tg),
            ntb = tb<0?tb+1:(tb>1?tb-1:tb),
            B = 255*(6*ntr<1?p+(q-p)*6*ntr:(2*ntr<1?q:(3*ntr<2?p+(q-p)*6*(2.0f*OneThird-ntr):p))),
            G = 255*(6*ntg<1?p+(q-p)*6*ntg:(2*ntg<1?q:(3*ntg<2?p+(q-p)*6*(2.0f*OneThird-ntg):p))),
            R = 255*(6*ntb<1?p+(q-p)*6*ntb:(2*ntb<1?q:(3*ntb<2?p+(q-p)*6*(2.0f*OneThird-ntb):p)));
        *ARGB &= 0xFF000000;
        *ARGB |= RGB( (BYTE)(R<0?0:(R>255?255:R)), (BYTE)(G<0?0:(G>255?255:G)), (BYTE)(B<0?0:(B>255?255:B)) );
    }

    static COLORREF PixelAlpha(COLORREF clrSrc, double src_darken, COLORREF clrDest, double dest_darken)
    {
        return RGB (GetRValue (clrSrc) * src_darken + GetRValue (clrDest) * dest_darken, 
            GetGValue (clrSrc) * src_darken + GetGValue (clrDest) * dest_darken, 
            GetBValue (clrSrc) * src_darken + GetBValue (clrDest) * dest_darken);
    }

    static BOOL WINAPI AlphaBitBlt(HDC hDC, int nDestX, int nDestY, int dwWidth, int dwHeight, HDC hSrcDC, \
        int nSrcX, int nSrcY, int wSrc, int hSrc, BLENDFUNCTION ftn)
    {
        HDC hTempDC = ::CreateCompatibleDC(hDC);
        if (NULL == hTempDC)
            return FALSE;

        //Creates Source DIB
        LPBITMAPINFO lpbiSrc = NULL;
        // Fill in the BITMAPINFOHEADER
        lpbiSrc = (LPBITMAPINFO) new BYTE[sizeof(BITMAPINFOHEADER)];
        if (lpbiSrc == NULL)
        {
            ::DeleteDC(hTempDC);
            return FALSE;
        }
        lpbiSrc->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        lpbiSrc->bmiHeader.biWidth = dwWidth;
        lpbiSrc->bmiHeader.biHeight = dwHeight;
        lpbiSrc->bmiHeader.biPlanes = 1;
        lpbiSrc->bmiHeader.biBitCount = 32;
        lpbiSrc->bmiHeader.biCompression = BI_RGB;
        lpbiSrc->bmiHeader.biSizeImage = dwWidth * dwHeight;
        lpbiSrc->bmiHeader.biXPelsPerMeter = 0;
        lpbiSrc->bmiHeader.biYPelsPerMeter = 0;
        lpbiSrc->bmiHeader.biClrUsed = 0;
        lpbiSrc->bmiHeader.biClrImportant = 0;

        COLORREF* pSrcBits = NULL;
        HBITMAP hSrcDib = CreateDIBSection (
            hSrcDC, lpbiSrc, DIB_RGB_COLORS, (void **)&pSrcBits,
            NULL, NULL);

        if ((NULL == hSrcDib) || (NULL == pSrcBits)) 
        {
            delete [] lpbiSrc;
            ::DeleteDC(hTempDC);
            return FALSE;
        }

        HBITMAP hOldTempBmp = (HBITMAP)::SelectObject (hTempDC, hSrcDib);
        ::StretchBlt(hTempDC, 0, 0, dwWidth, dwHeight, hSrcDC, nSrcX, nSrcY, wSrc, hSrc, SRCCOPY);
        ::SelectObject (hTempDC, hOldTempBmp);

        //Creates Destination DIB
        LPBITMAPINFO lpbiDest = NULL;
        // Fill in the BITMAPINFOHEADER
        lpbiDest = (LPBITMAPINFO) new BYTE[sizeof(BITMAPINFOHEADER)];
        if (lpbiDest == NULL)
        {
            delete [] lpbiSrc;
            ::DeleteObject(hSrcDib);
            ::DeleteDC(hTempDC);
            return FALSE;
        }

        lpbiDest->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        lpbiDest->bmiHeader.biWidth = dwWidth;
        lpbiDest->bmiHeader.biHeight = dwHeight;
        lpbiDest->bmiHeader.biPlanes = 1;
        lpbiDest->bmiHeader.biBitCount = 32;
        lpbiDest->bmiHeader.biCompression = BI_RGB;
        lpbiDest->bmiHeader.biSizeImage = dwWidth * dwHeight;
        lpbiDest->bmiHeader.biXPelsPerMeter = 0;
        lpbiDest->bmiHeader.biYPelsPerMeter = 0;
        lpbiDest->bmiHeader.biClrUsed = 0;
        lpbiDest->bmiHeader.biClrImportant = 0;

        COLORREF* pDestBits = NULL;
        HBITMAP hDestDib = CreateDIBSection (
            hDC, lpbiDest, DIB_RGB_COLORS, (void **)&pDestBits,
            NULL, NULL);

        if ((NULL == hDestDib) || (NULL == pDestBits))
        {
            delete [] lpbiSrc;
            ::DeleteObject(hSrcDib);
            ::DeleteDC(hTempDC);
            return FALSE;
        }

        ::SelectObject (hTempDC, hDestDib);
        ::BitBlt (hTempDC, 0, 0, dwWidth, dwHeight, hDC, nDestX, nDestY, SRCCOPY);
        ::SelectObject (hTempDC, hOldTempBmp);

        double src_darken;
        BYTE nAlpha;

        for (int pixel = 0; pixel < dwWidth * dwHeight; pixel++, pSrcBits++, pDestBits++)
        {
            nAlpha = LOBYTE(*pSrcBits >> 24);
            src_darken = (double) (nAlpha * ftn.SourceConstantAlpha) / 255.0 / 255.0;
            if( src_darken < 0.0 ) src_darken = 0.0;
            *pDestBits = PixelAlpha(*pSrcBits, src_darken, *pDestBits, 1.0 - src_darken);
        } //for

        ::SelectObject (hTempDC, hDestDib);
        ::BitBlt (hDC, nDestX, nDestY, dwWidth, dwHeight, hTempDC, 0, 0, SRCCOPY);
        ::SelectObject (hTempDC, hOldTempBmp);

        delete [] lpbiDest;
        ::DeleteObject(hDestDib);

        delete [] lpbiSrc;
        ::DeleteObject(hSrcDib);

        ::DeleteDC(hTempDC);
        return TRUE;
    }

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    bool DrawImage(HDC hDC, CPaintManagerUI* pManager, const RECT& rc, const RECT& rcPaint, const CDuiString& sImageName, \
        const CDuiString& sImageResType, RECT rcItem, RECT rcBmpPart, RECT rcCorner, DWORD dwMask, BYTE bFade, \
        bool bHole, bool bTiledX, bool bTiledY, HINSTANCE instance = NULL)
    {
        if (sImageName.IsEmpty()) {
            return false;
        }
        const TImageInfo* data = NULL;
        if( sImageResType.IsEmpty() ) {
            data = pManager->GetImageEx((LPCTSTR)sImageName, NULL, dwMask, false, instance);
        }
        else {
            data = pManager->GetImageEx((LPCTSTR)sImageName, (LPCTSTR)sImageResType, dwMask, false, instance);
        }
        if( !data ) return false;    

        if( rcBmpPart.left == 0 && rcBmpPart.right == 0 && rcBmpPart.top == 0 && rcBmpPart.bottom == 0 ) {
            rcBmpPart.right = data->nX;
            rcBmpPart.bottom = data->nY;
        }
        if (rcBmpPart.right > data->nX) rcBmpPart.right = data->nX;
        if (rcBmpPart.bottom > data->nY) rcBmpPart.bottom = data->nY;

        RECT rcTemp;
        if( !::IntersectRect(&rcTemp, &rcItem, &rc) ) return true;
        if( !::IntersectRect(&rcTemp, &rcItem, &rcPaint) ) return true;

        CRenderEngine::DrawImage(hDC, data->hBitmap, rcItem, rcPaint, rcBmpPart, rcCorner, pManager->IsLayered() ? true : data->bAlpha, bFade, bHole, bTiledX, bTiledY);

        return true;
    }

    DWORD CRenderEngine::AdjustColor(DWORD dwColor, short H, short S, short L)
    {
        if( H == 180 && S == 100 && L == 100 ) return dwColor;
        float fH, fS, fL;
        float S1 = S / 100.0f;
        float L1 = L / 100.0f;
        RGBtoHSL(dwColor, &fH, &fS, &fL);
        fH += (H - 180);
        fH = fH > 0 ? fH : fH + 360; 
        fS *= S1;
        fL *= L1;
        HSLtoRGB(&dwColor, fH, fS, fL);
        return dwColor;
    }

    TImageInfo* CRenderEngine::LoadImage(STRINGorID bitmap, LPCTSTR type, DWORD mask, HINSTANCE instance)
    {
        LPBYTE pData = NULL;
        DWORD dwSize = 0;
        do 
        {
            if( type == NULL ) {
                CDuiString sFile = CPaintManagerUI::GetResourcePath();
                if( CPaintManagerUI::GetResourceZip().IsEmpty() ) {
                    sFile += bitmap.m_lpstr;
                    HANDLE hFile = ::CreateFile(sFile.GetData(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
                        FILE_ATTRIBUTE_NORMAL, NULL);
                    if( hFile == INVALID_HANDLE_VALUE ) break;
                    dwSize = ::GetFileSize(hFile, NULL);
                    if( dwSize == 0 ) break;

                    DWORD dwRead = 0;
                    pData = new BYTE[ dwSize ];
                    ::ReadFile( hFile, pData, dwSize, &dwRead, NULL );
                    ::CloseHandle( hFile );

                    if( dwRead != dwSize ) {
                        delete[] pData;
                        pData = NULL;
                        break;
                    }
                }
                else {
                    sFile += CPaintManagerUI::GetResourceZip();
                    CDuiString sFilePwd = CPaintManagerUI::GetResourceZipPwd();
                    HZIP hz = NULL;
                    if( CPaintManagerUI::IsCachedResourceZip() ) hz = (HZIP)CPaintManagerUI::GetResourceZipHandle();
                    else
                    {
#ifdef UNICODE
                        char* pwd = w2a((wchar_t*)sFilePwd.GetData());
                        hz = OpenZip(sFile.GetData(), pwd);
                        if(pwd) delete[] pwd;
#else
                        hz = OpenZip(sFile.GetData(), sFilePwd.GetData());
#endif
                    }
                    if( hz == NULL ) break;
                    ZIPENTRY ze; 
                    int i = 0; 
                    CDuiString key = bitmap.m_lpstr;
                    key.Replace(_T("\\"), _T("/"));
                    if( FindZipItem(hz, key, true, &i, &ze) != 0 ) break;
                    dwSize = ze.unc_size;
                    if( dwSize == 0 ) break;
                    pData = new BYTE[ dwSize ];
                    int res = UnzipItem(hz, i, pData, dwSize);
                    if( res != 0x00000000 && res != 0x00000600) {
                        delete[] pData;
                        pData = NULL;
                        if( !CPaintManagerUI::IsCachedResourceZip() ) CloseZip(hz);
                        break;
                    }
                    if( !CPaintManagerUI::IsCachedResourceZip() ) CloseZip(hz);
                }
            }
            else {
                HINSTANCE dllinstance = NULL;
                if (instance) {
                    dllinstance = instance;
                }
                else {
                    dllinstance = CPaintManagerUI::GetResourceDll();
                }
                HRSRC hResource = ::FindResource(dllinstance, bitmap.m_lpstr, type);
                if( hResource == NULL ) break;
                HGLOBAL hGlobal = ::LoadResource(dllinstance, hResource);
                if( hGlobal == NULL ) {
                    FreeResource(hResource);
                    break;
                }

                dwSize = ::SizeofResource(dllinstance, hResource);
                if( dwSize == 0 ) break;
                pData = new BYTE[ dwSize ];
                ::CopyMemory(pData, (LPBYTE)::LockResource(hGlobal), dwSize);
                ::FreeResource(hResource);
            }
        } while (0);

        while (!pData)
        {
            //读不到图片, 则直接去读取bitmap.m_lpstr指向的路径
            HANDLE hFile = ::CreateFile(bitmap.m_lpstr, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
                FILE_ATTRIBUTE_NORMAL, NULL);
            if( hFile == INVALID_HANDLE_VALUE ) break;
            dwSize = ::GetFileSize(hFile, NULL);
            if( dwSize == 0 ) break;

            DWORD dwRead = 0;
            pData = new BYTE[ dwSize ];
            ::ReadFile( hFile, pData, dwSize, &dwRead, NULL );
            ::CloseHandle( hFile );

            if( dwRead != dwSize ) {
                delete[] pData;
                pData = NULL;
            }
            break;
        }
        if (!pData)
        {
            return NULL;
        }

        LPBYTE pImage = NULL;
        int x,y,n;
        pImage = stbi_load_from_memory(pData, dwSize, &x, &y, &n, 4);
        delete[] pData;
        if( !pImage ) {
            return NULL;
        }

        BITMAPINFO bmi;
        ::ZeroMemory(&bmi, sizeof(BITMAPINFO));
        bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        bmi.bmiHeader.biWidth = x;
        bmi.bmiHeader.biHeight = -y;
        bmi.bmiHeader.biPlanes = 1;
        bmi.bmiHeader.biBitCount = 32;
        bmi.bmiHeader.biCompression = BI_RGB;
        bmi.bmiHeader.biSizeImage = x * y * 4;

        bool bAlphaChannel = false;
        LPBYTE pDest = NULL;
        HBITMAP hBitmap = ::CreateDIBSection(NULL, &bmi, DIB_RGB_COLORS, (void**)&pDest, NULL, 0);
        if( !hBitmap ) {
            return NULL;
        }

        for( int i = 0; i < x * y; i++ ) 
        {
            pDest[i*4 + 3] = pImage[i*4 + 3];
            if( pDest[i*4 + 3] < 255 )
            {
                pDest[i*4] = (BYTE)(DWORD(pImage[i*4 + 2])*pImage[i*4 + 3]/255);
                pDest[i*4 + 1] = (BYTE)(DWORD(pImage[i*4 + 1])*pImage[i*4 + 3]/255);
                pDest[i*4 + 2] = (BYTE)(DWORD(pImage[i*4])*pImage[i*4 + 3]/255); 
                bAlphaChannel = true;
            }
            else
            {
                pDest[i*4] = pImage[i*4 + 2];
                pDest[i*4 + 1] = pImage[i*4 + 1];
                pDest[i*4 + 2] = pImage[i*4]; 
            }

            if( *(DWORD*)(&pDest[i*4]) == mask ) {
                pDest[i*4] = (BYTE)0;
                pDest[i*4 + 1] = (BYTE)0;
                pDest[i*4 + 2] = (BYTE)0; 
                pDest[i*4 + 3] = (BYTE)0;
                bAlphaChannel = true;
            }
        }

        stbi_image_free(pImage);

        TImageInfo* data = new TImageInfo;
        data->pBits = NULL;
        data->pSrcBits = NULL;
        data->hBitmap = hBitmap;
        data->nX = x;
        data->nY = y;
        data->bAlpha = bAlphaChannel;
        return data;
    }
#ifdef USE_XIMAGE_EFFECT
    static DWORD LoadImage2Memory(const STRINGorID &bitmap, LPCTSTR type,LPBYTE &pData)
    {
        assert(pData == NULL);
        pData = NULL;
        DWORD dwSize(0U);
        do 
        {
            if( type == NULL )
            {
                CDuiString sFile = CPaintManagerUI::GetResourcePath();
                if( CPaintManagerUI::GetResourceZip().IsEmpty() )
                {
                    sFile += bitmap.m_lpstr;
                    HANDLE hFile = ::CreateFile(sFile.GetData(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
                        FILE_ATTRIBUTE_NORMAL, NULL);
                    if( hFile == INVALID_HANDLE_VALUE ) break;
                    dwSize = ::GetFileSize(hFile, NULL);
                    if( dwSize == 0 ) break;

                    DWORD dwRead = 0;
                    pData = new BYTE[ dwSize + 1 ];
                    memset(pData,0,dwSize+1);
                    ::ReadFile( hFile, pData, dwSize, &dwRead, NULL );
                    ::CloseHandle( hFile );

                    if( dwRead != dwSize ) 
                    {
                        delete[] pData;
                        pData = NULL;
                        dwSize = 0U;
                        break;
                    }
                }
                else 
                {
                    sFile += CPaintManagerUI::GetResourceZip();
                    HZIP hz = NULL;
                    if( CPaintManagerUI::IsCachedResourceZip() ) 
                        hz = (HZIP)CPaintManagerUI::GetResourceZipHandle();
                    else {
                        CDuiString sFilePwd = CPaintManagerUI::GetResourceZipPwd();
#ifdef UNICODE
                        char* pwd = w2a((wchar_t*)sFilePwd.GetData());
                        hz = OpenZip((void*)sFile.GetData(), pwd);
                        if(pwd) delete[] pwd;
#else
                        hz = OpenZip((void*)sFile.GetData(), sFilePwd.GetData());
#endif
                    }
                    if( hz == NULL ) break;
                    ZIPENTRY ze; 
                    int i = 0; 
                    CDuiString key = bitmap.m_lpstr;
                    key.Replace(_T("\\"), _T("/")); 
                    if( FindZipItem(hz, key, true, &i, &ze) != 0 ) break;
                    dwSize = ze.unc_size;
                    if( dwSize == 0 ) break;
                    pData = new BYTE[ dwSize ];
                    int res = UnzipItem(hz, i, pData, dwSize, 3);
                    if( res != 0x00000000 && res != 0x00000600)
                    {
                        delete[] pData;
                        pData = NULL;
                        dwSize = 0U;
                        if( !CPaintManagerUI::IsCachedResourceZip() )
                            CloseZip(hz);
                        break;
                    }
                    if( !CPaintManagerUI::IsCachedResourceZip() )
                        CloseZip(hz);
                }
            }
            else 
            {
                HINSTANCE hDll = CPaintManagerUI::GetResourceDll();
                HRSRC hResource = ::FindResource(hDll, bitmap.m_lpstr, type);
                if( hResource == NULL ) break;
                HGLOBAL hGlobal = ::LoadResource(hDll, hResource);
                if( hGlobal == NULL ) 
                {
                    FreeResource(hResource);
                    break;
                }

                dwSize = ::SizeofResource(hDll, hResource);
                if( dwSize == 0 ) break;
                pData = new BYTE[ dwSize ];
                ::CopyMemory(pData, (LPBYTE)::LockResource(hGlobal), dwSize);
                ::FreeResource(hResource);
            }
        } while (0);

        while (!pData)
        {
            //读不到图片, 则直接去读取bitmap.m_lpstr指向的路径
            HANDLE hFile = ::CreateFile(bitmap.m_lpstr, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
                FILE_ATTRIBUTE_NORMAL, NULL);
            if( hFile == INVALID_HANDLE_VALUE ) break;
            dwSize = ::GetFileSize(hFile, NULL);
            if( dwSize == 0 ) break;

            DWORD dwRead = 0;
            pData = new BYTE[ dwSize ];
            ::ReadFile( hFile, pData, dwSize, &dwRead, NULL );
            ::CloseHandle( hFile );

            if( dwRead != dwSize ) 
            {
                delete[] pData;
                pData = NULL;
                dwSize = 0U;
            }
            break;
        }
        return dwSize;
    }
    CxImage* CRenderEngine::LoadGifImageX(STRINGorID bitmap, LPCTSTR type , DWORD mask)
    {
        //write by wangji
        LPBYTE pData = NULL;
        DWORD dwSize = LoadImage2Memory(bitmap,type,pData);
        if(dwSize == 0U || !pData)
            return NULL;
        CxImage * pImg = NULL;
        if(pImg = new CxImage())
        {
            pImg->SetRetreiveAllFrames(TRUE);
            if(!pImg->Decode(pData,dwSize,CXIMAGE_FORMAT_GIF))
            {
                delete pImg;
                pImg = nullptr;
            }
        }
        delete[] pData;
        pData = NULL;
        return pImg;
    }
#endif//USE_XIMAGE_EFFECT

    Gdiplus::Image* CRenderEngine::GdiplusLoadImage(LPCTSTR pstrPath)
    {
        LPBYTE pData = NULL;
        DWORD dwSize = 0;

        do 
        {
            CDuiString sFile = CPaintManagerUI::GetResourcePath();
            if( CPaintManagerUI::GetResourceZip().IsEmpty() ) {
                sFile += pstrPath;
                HANDLE hFile = ::CreateFile(sFile.GetData(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
                    FILE_ATTRIBUTE_NORMAL, NULL);
                if( hFile == INVALID_HANDLE_VALUE ) break;
                dwSize = ::GetFileSize(hFile, NULL);
                if( dwSize == 0 ) break;

                DWORD dwRead = 0;
                pData = new BYTE[ dwSize ];
                ::ReadFile( hFile, pData, dwSize, &dwRead, NULL );
                ::CloseHandle( hFile );

                if( dwRead != dwSize ) {
                    delete[] pData;
                    pData = NULL;
                    break;
                }
            }
            else {
                sFile += CPaintManagerUI::GetResourceZip();
                HZIP hz = NULL;
                if( CPaintManagerUI::IsCachedResourceZip() ) hz = (HZIP)CPaintManagerUI::GetResourceZipHandle();
                else {
                    CDuiString sFilePwd = CPaintManagerUI::GetResourceZipPwd();
#ifdef UNICODE
                    char* pwd = w2a((wchar_t*)sFilePwd.GetData());
                    hz = OpenZip(sFile.GetData(), pwd);
                    if(pwd) delete[] pwd;
#else
                    hz = OpenZip(sFile.GetData(), sFilePwd.GetData());
#endif
                }
                if( hz == NULL ) break;
                ZIPENTRY ze; 
                int i = 0; 
                CDuiString key = pstrPath;
                key.Replace(_T("\\"), _T("/"));
                if( FindZipItem(hz, key, true, &i, &ze) != 0 ) break;
                dwSize = ze.unc_size;
                if( dwSize == 0 ) break;
                pData = new BYTE[ dwSize ];
                int res = UnzipItem(hz, i, pData, dwSize);
                if( res != 0x00000000 && res != 0x00000600) {
                    delete[] pData;
                    pData = NULL;
                    if( !CPaintManagerUI::IsCachedResourceZip() ) CloseZip(hz);
                    break;
                }
                if( !CPaintManagerUI::IsCachedResourceZip() ) CloseZip(hz);
            }

        } while (0);

        while (!pData)
        {
            //读不到图片, 则直接去读取bitmap.m_lpstr指向的路径
            HANDLE hFile = ::CreateFile(pstrPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
            if( hFile == INVALID_HANDLE_VALUE ) break;
            dwSize = ::GetFileSize(hFile, NULL);
            if( dwSize == 0 ) break;

            DWORD dwRead = 0;
            pData = new BYTE[ dwSize ];
            ::ReadFile( hFile, pData, dwSize, &dwRead, NULL );
            ::CloseHandle( hFile );

            if( dwRead != dwSize ) {
                delete[] pData;
                pData = NULL;
            }
            break;
        }

        Gdiplus::Image* pImage = NULL;
        if(pData != NULL) {
            pImage = GdiplusLoadImage(pData, dwSize);
            delete[] pData;
            pData = NULL;
        }
        return pImage;
    }

    Gdiplus::Image* CRenderEngine::GdiplusLoadImage( LPVOID pBuf,size_t dwSize )
    {
        HGLOBAL hMem = ::GlobalAlloc(GMEM_FIXED, dwSize);
        BYTE* pMem = (BYTE*)::GlobalLock(hMem);
        memcpy(pMem, pBuf, dwSize);
        IStream* pStm = NULL;
        ::CreateStreamOnHGlobal(hMem, TRUE, &pStm);
        Gdiplus::Image *pImg = Gdiplus::Image::FromStream(pStm);
        if(!pImg || pImg->GetLastStatus() != Gdiplus::Ok)
        {
            pStm->Release();
            ::GlobalUnlock(hMem);
            return 0;
        }
        return pImg;
    }

    void CRenderEngine::FreeImage(TImageInfo* bitmap, bool bDelete)
    {
        if (bitmap == NULL) return;
        if (bitmap->hBitmap) {
            ::DeleteObject(bitmap->hBitmap);
        }
        bitmap->hBitmap = NULL;
        if (bitmap->pBits) {
            delete[] bitmap->pBits;
        }
        bitmap->pBits = NULL;
        if (bitmap->pSrcBits) {
            delete[] bitmap->pSrcBits;
        }
        bitmap->pSrcBits = NULL;
        if (bDelete) {
            delete bitmap;
            bitmap = NULL;
        }
    }


    bool CRenderEngine::DrawIconImageString(HDC hDC, CPaintManagerUI* pManager, const RECT& rc, const RECT& rcPaint, LPCTSTR pStrImage, LPCTSTR pStrModify)
    {
        if ((pManager == NULL) || (hDC == NULL)) 
            return false;

        // 1、aaa.jpg
        // 2、file='aaa.jpg' res='' restype='0' dest='0,0,0,0' source='0,0,0,0' corner='0,0,0,0' 
        // mask='#FF0000' fade='255' hole='FALSE' xtiled='FALSE' ytiled='FALSE'

        CDuiString sImageName = pStrImage;
        CDuiString sImageResType;
        RECT rcItem = rc;
        RECT rcBmpPart = {0};
        RECT rcCorner = {0};
        DWORD dwMask = 0;
        BYTE bFade = 0xFF;
        bool bHole = false;
        bool bTiledX = true;
        bool bTiledY = true;
        CDuiSize szIcon(0,0);

        int image_count = 0;

        CDuiString sItem;
        CDuiString sValue;
        LPTSTR pstr = NULL;

        for( int i = 0; i < 2; ++i,image_count = 0 ) {
            if( i == 1)
                pStrImage = pStrModify;

            if( !pStrImage ) continue;

            while( *pStrImage != _T('\0') ) {
                sItem.Empty();
                sValue.Empty();
                while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
                while( *pStrImage != _T('\0') && *pStrImage != _T('=') && *pStrImage > _T(' ') ) {
                    LPTSTR pstrTemp = ::CharNext(pStrImage);
                    while( pStrImage < pstrTemp) {
                        sItem += *pStrImage++;
                    }
                }
                while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
                if( *pStrImage++ != _T('=') ) break;
                while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
                if( *pStrImage++ != _T('\'') ) break;
                while( *pStrImage != _T('\0') && *pStrImage != _T('\'') ) {
                    LPTSTR pstrTemp = ::CharNext(pStrImage);
                    while( pStrImage < pstrTemp) {
                        sValue += *pStrImage++;
                    }
                }
                if( *pStrImage++ != _T('\'') ) 
                    break;

                if( !sValue.IsEmpty() ) 
                {
                    if( sItem == _T("file") || sItem == _T("res") )
                    {
                        if( image_count > 0 )
                            DuiLib::DrawImage(hDC, pManager, rc, rcPaint, sImageName, sImageResType,
                            rcItem, rcBmpPart, rcCorner, dwMask, bFade, bHole, bTiledX, bTiledY);

                        sImageName = sValue;
                        ++image_count;
                    }
                    else if( sItem == _T("restype") ) 
                    {
                        if( image_count > 0 )
                            DuiLib::DrawImage(hDC, pManager, rc, rcPaint, sImageName, sImageResType,
                            rcItem, rcBmpPart, rcCorner, dwMask, bFade, bHole, bTiledX, bTiledY);

                        sImageResType = sValue;
                        ++image_count;
                    }
                    else if( sItem == _T("dest") ) 
                    {
                        rcItem.left = rc.left + _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);    
                        rcItem.top = rc.top + _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
                        rcItem.right = rc.left + _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);

                        if (rcItem.right > rc.right) 
                            rcItem.right = rc.right;

                        rcItem.bottom = rc.top + _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
                        if (rcItem.bottom > rc.bottom) 
                            rcItem.bottom = rc.bottom;
                    }
                    else if( sItem == _T("source") ) 
                    {
                        rcBmpPart.left = _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);    
                        rcBmpPart.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
                        rcBmpPart.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
                        rcBmpPart.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);  
                    }
                    else if( sItem == _T("corner") ) 
                    {
                        rcCorner.left = _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);    
                        rcCorner.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
                        rcCorner.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
                        rcCorner.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
                    }
                    else if( sItem == _T("mask") ) 
                    {
                        if( sValue[0] == _T('#')) dwMask = _tcstoul(sValue.GetData() + 1, &pstr, 16);
                        else dwMask = _tcstoul(sValue.GetData(), &pstr, 16);
                    }
                    else if( sItem == _T("fade") ) 
                    {
                        bFade = (BYTE)_tcstoul(sValue.GetData(), &pstr, 10);
                    }
                    else if( sItem == _T("hole") )
                    {
                        bHole = (_tcsicmp(sValue.GetData(), _T("TRUE")) == 0);
                    }
                    else if( sItem == _T("xtiled") ) 
                    {
                        bTiledX = (_tcsicmp(sValue.GetData(), _T("TRUE")) == 0);
                    }
                    else if( sItem == _T("ytiled") )
                    {
                        bTiledY = (_tcsicmp(sValue.GetData(), _T("TRUE")) == 0);
                    }
                    else if( sItem == _T("iconsize") )
                    {
                        szIcon.cx = _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);
                        szIcon.cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
                    }
                    else if( sItem == _T("iconalign") )
                    {
                        MakeFitIconDest(rcItem, szIcon, sValue, rcItem);
                    }
                }
                if( *pStrImage++ != _T(' ') ) 
                    break;
            }
        }

        DuiLib::DrawImage(hDC, pManager, rc, rcPaint, sImageName, sImageResType, rcItem, rcBmpPart, rcCorner, dwMask, bFade, bHole, bTiledX, bTiledY);

        return true;
    }

    bool CRenderEngine::MakeFitIconDest(const RECT& rcControl,const CDuiSize& szIcon, const CDuiString& sAlign, RECT& rcDest)
    {
        ASSERT(!sAlign.IsEmpty());
        if(sAlign == _T("left"))
        {
            rcDest.left = rcControl.left;  
            rcDest.top = rcControl.top;
            rcDest.right = rcDest.left + szIcon.cx;
            rcDest.bottom = rcDest.top + szIcon.cy;
        }
        else if( sAlign == _T("center") ) 
        {
            rcDest.left = rcControl.left + ((rcControl.right - rcControl.left) - szIcon.cx)/2;  
            rcDest.top = rcControl.top + ((rcControl.bottom - rcControl.top) - szIcon.cy)/2;
            rcDest.right = rcDest.left + szIcon.cx;
            rcDest.bottom = rcDest.top + szIcon.cy;
        }
        else if( sAlign == _T("vcenter") )
        {
            rcDest.left = rcControl.left;  
            rcDest.top = rcControl.top + ((rcControl.bottom - rcControl.top) - szIcon.cy)/2;
            rcDest.right = rcDest.left + szIcon.cx;
            rcDest.bottom = rcDest.top + szIcon.cy;
        }
        else if( sAlign == _T("hcenter") )
        {
            rcDest.left = rcControl.left + ((rcControl.right - rcControl.left) - szIcon.cx)/2;  
            rcDest.top = rcControl.top;
            rcDest.right = rcDest.left + szIcon.cx;
            rcDest.bottom = rcDest.top + szIcon.cy;
        }

        if (rcDest.right > rcControl.right) 
            rcDest.right = rcControl.right;

        if (rcDest.bottom > rcControl.bottom) 
            rcDest.bottom = rcControl.bottom;

        return true;
    }

    TImageInfo* CRenderEngine::LoadImage(LPCTSTR pStrImage, LPCTSTR type, DWORD mask, HINSTANCE instance)
    {    
        if(pStrImage == NULL) return NULL;

        CDuiString sStrPath = pStrImage;
        if( type == NULL )  {
            sStrPath = CResourceManager::GetInstance()->GetImagePath(pStrImage);
            if (sStrPath.IsEmpty()) sStrPath = pStrImage;
            else {
                /*if (CResourceManager::GetInstance()->GetScale() != 100) {
                CDuiString sScale;
                sScale.Format(_T("@%d."), CResourceManager::GetInstance()->GetScale());
                sStrPath.Replace(_T("."), sScale);
                }*/
            }
        }
        return LoadImage(STRINGorID(sStrPath.GetData()), type, mask, instance);
    }

    TImageInfo* CRenderEngine::LoadImage(UINT nID, LPCTSTR type, DWORD mask, HINSTANCE instance)
    {
        return LoadImage(STRINGorID(nID), type, mask, instance);
    }

    void CRenderEngine::DrawText(HDC hDC, CPaintManagerUI* pManager, RECT& rc, LPCTSTR pstrText,DWORD dwTextColor, \
        int iFont, UINT uStyle, DWORD dwTextBKColor)
    {
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
        if( pstrText == NULL || pManager == NULL ) return;
        DrawColor(hDC, rc, dwTextBKColor);
        DrawText(hDC, pManager, rc, pstrText, dwTextColor, iFont, uStyle);
    }

    void CRenderEngine::DrawImage(HDC hDC, HBITMAP hBitmap, const RECT& rc, const RECT& rcPaint,
        const RECT& rcBmpPart, const RECT& rcCorners, bool bAlpha, 
        BYTE uFade, bool hole, bool xtiled, bool ytiled)
    {
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);

        typedef BOOL (WINAPI *LPALPHABLEND)(HDC, int, int, int, int,HDC, int, int, int, int, BLENDFUNCTION);
        static LPALPHABLEND lpAlphaBlend = (LPALPHABLEND) ::GetProcAddress(::GetModuleHandle(_T("msimg32.dll")), "AlphaBlend");

        if( lpAlphaBlend == NULL ) lpAlphaBlend = AlphaBitBlt;
        if( hBitmap == NULL ) return;

        HDC hCloneDC = ::CreateCompatibleDC(hDC);
        HBITMAP hOldBitmap = (HBITMAP) ::SelectObject(hCloneDC, hBitmap);
        ::SetStretchBltMode(hDC, HALFTONE);

        RECT rcTemp = {0};
        RECT rcDest = {0};
        if( lpAlphaBlend && (bAlpha || uFade < 255) ) {
            BLENDFUNCTION bf = { AC_SRC_OVER, 0, uFade, AC_SRC_ALPHA };
            // middle
            if( !hole ) {
                rcDest.left = rc.left + rcCorners.left;
                rcDest.top = rc.top + rcCorners.top;
                rcDest.right = rc.right - rc.left - rcCorners.left - rcCorners.right;
                rcDest.bottom = rc.bottom - rc.top - rcCorners.top - rcCorners.bottom;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    if( !xtiled && !ytiled ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, \
                            rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right, \
                            rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom, bf);
                    }
                    else if( xtiled && ytiled ) {
                        LONG lWidth = rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right;
                        LONG lHeight = rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom;
                        int iTimesX = (rcDest.right - rcDest.left + lWidth - 1) / lWidth;
                        int iTimesY = (rcDest.bottom - rcDest.top + lHeight - 1) / lHeight;
                        for( int j = 0; j < iTimesY; ++j ) {
                            LONG lDestTop = rcDest.top + lHeight * j;
                            LONG lDestBottom = rcDest.top + lHeight * (j + 1);
                            LONG lDrawHeight = lHeight;
                            if( lDestBottom > rcDest.bottom ) {
                                lDrawHeight -= lDestBottom - rcDest.bottom;
                                lDestBottom = rcDest.bottom;
                            }
                            for( int i = 0; i < iTimesX; ++i ) {
                                LONG lDestLeft = rcDest.left + lWidth * i;
                                LONG lDestRight = rcDest.left + lWidth * (i + 1);
                                LONG lDrawWidth = lWidth;
                                if( lDestRight > rcDest.right ) {
                                    lDrawWidth -= lDestRight - rcDest.right;
                                    lDestRight = rcDest.right;
                                }
                                lpAlphaBlend(hDC, rcDest.left + lWidth * i, rcDest.top + lHeight * j, 
                                    lDestRight - lDestLeft, lDestBottom - lDestTop, hCloneDC, 
                                    rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, lDrawWidth, lDrawHeight, bf);
                            }
                        }
                    }
                    else if( xtiled ) {
                        LONG lWidth = rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right;
                        int iTimes = (rcDest.right - rcDest.left + lWidth - 1) / lWidth;
                        for( int i = 0; i < iTimes; ++i ) {
                            LONG lDestLeft = rcDest.left + lWidth * i;
                            LONG lDestRight = rcDest.left + lWidth * (i + 1);
                            LONG lDrawWidth = lWidth;
                            if( lDestRight > rcDest.right ) {
                                lDrawWidth -= lDestRight - rcDest.right;
                                lDestRight = rcDest.right;
                            }
                            lpAlphaBlend(hDC, lDestLeft, rcDest.top, lDestRight - lDestLeft, rcDest.bottom, 
                                hCloneDC, rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, \
                                lDrawWidth, rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom, bf);
                        }
                    }
                    else { // ytiled
                        LONG lHeight = rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom;
                        int iTimes = (rcDest.bottom - rcDest.top + lHeight - 1) / lHeight;
                        for( int i = 0; i < iTimes; ++i ) {
                            LONG lDestTop = rcDest.top + lHeight * i;
                            LONG lDestBottom = rcDest.top + lHeight * (i + 1);
                            LONG lDrawHeight = lHeight;
                            if( lDestBottom > rcDest.bottom ) {
                                lDrawHeight -= lDestBottom - rcDest.bottom;
                                lDestBottom = rcDest.bottom;
                            }
                            lpAlphaBlend(hDC, rcDest.left, rcDest.top + lHeight * i, rcDest.right, lDestBottom - lDestTop, 
                                hCloneDC, rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, \
                                rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right, lDrawHeight, bf);                    
                        }
                    }
                }
            }

            // left-top
            if( rcCorners.left > 0 && rcCorners.top > 0 ) {
                rcDest.left = rc.left;
                rcDest.top = rc.top;
                rcDest.right = rcCorners.left;
                rcDest.bottom = rcCorners.top;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.left, rcBmpPart.top, rcCorners.left, rcCorners.top, bf);
                }
            }
            // top
            if( rcCorners.top > 0 ) {
                rcDest.left = rc.left + rcCorners.left;
                rcDest.top = rc.top;
                rcDest.right = rc.right - rc.left - rcCorners.left - rcCorners.right;
                rcDest.bottom = rcCorners.top;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.left + rcCorners.left, rcBmpPart.top, rcBmpPart.right - rcBmpPart.left - \
                        rcCorners.left - rcCorners.right, rcCorners.top, bf);
                }
            }
            // right-top
            if( rcCorners.right > 0 && rcCorners.top > 0 ) {
                rcDest.left = rc.right - rcCorners.right;
                rcDest.top = rc.top;
                rcDest.right = rcCorners.right;
                rcDest.bottom = rcCorners.top;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.right - rcCorners.right, rcBmpPart.top, rcCorners.right, rcCorners.top, bf);
                }
            }
            // left
            if( rcCorners.left > 0 ) {
                rcDest.left = rc.left;
                rcDest.top = rc.top + rcCorners.top;
                rcDest.right = rcCorners.left;
                rcDest.bottom = rc.bottom - rc.top - rcCorners.top - rcCorners.bottom;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.left, rcBmpPart.top + rcCorners.top, rcCorners.left, rcBmpPart.bottom - \
                        rcBmpPart.top - rcCorners.top - rcCorners.bottom, bf);
                }
            }
            // right
            if( rcCorners.right > 0 ) {
                rcDest.left = rc.right - rcCorners.right;
                rcDest.top = rc.top + rcCorners.top;
                rcDest.right = rcCorners.right;
                rcDest.bottom = rc.bottom - rc.top - rcCorners.top - rcCorners.bottom;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.right - rcCorners.right, rcBmpPart.top + rcCorners.top, rcCorners.right, \
                        rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom, bf);
                }
            }
            // left-bottom
            if( rcCorners.left > 0 && rcCorners.bottom > 0 ) {
                rcDest.left = rc.left;
                rcDest.top = rc.bottom - rcCorners.bottom;
                rcDest.right = rcCorners.left;
                rcDest.bottom = rcCorners.bottom;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.left, rcBmpPart.bottom - rcCorners.bottom, rcCorners.left, rcCorners.bottom, bf);
                }
            }
            // bottom
            if( rcCorners.bottom > 0 ) {
                rcDest.left = rc.left + rcCorners.left;
                rcDest.top = rc.bottom - rcCorners.bottom;
                rcDest.right = rc.right - rc.left - rcCorners.left - rcCorners.right;
                rcDest.bottom = rcCorners.bottom;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.left + rcCorners.left, rcBmpPart.bottom - rcCorners.bottom, \
                        rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right, rcCorners.bottom, bf);
                }
            }
            // right-bottom
            if( rcCorners.right > 0 && rcCorners.bottom > 0 ) {
                rcDest.left = rc.right - rcCorners.right;
                rcDest.top = rc.bottom - rcCorners.bottom;
                rcDest.right = rcCorners.right;
                rcDest.bottom = rcCorners.bottom;
                rcDest.right += rcDest.left;
                rcDest.bottom += rcDest.top;
                if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                    rcDest.right -= rcDest.left;
                    rcDest.bottom -= rcDest.top;
                    lpAlphaBlend(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                        rcBmpPart.right - rcCorners.right, rcBmpPart.bottom - rcCorners.bottom, rcCorners.right, \
                        rcCorners.bottom, bf);
                }
            }
        }
        else 
        {
            if (rc.right - rc.left == rcBmpPart.right - rcBmpPart.left \
                && rc.bottom - rc.top == rcBmpPart.bottom - rcBmpPart.top \
                && rcCorners.left == 0 && rcCorners.right == 0 && rcCorners.top == 0 && rcCorners.bottom == 0)
            {
                if( ::IntersectRect(&rcTemp, &rcPaint, &rc) ) {
                    ::BitBlt(hDC, rcTemp.left, rcTemp.top, rcTemp.right - rcTemp.left, rcTemp.bottom - rcTemp.top, \
                        hCloneDC, rcBmpPart.left + rcTemp.left - rc.left, rcBmpPart.top + rcTemp.top - rc.top, SRCCOPY);
                }
            }
            else
            {
                // middle
                if( !hole ) {
                    rcDest.left = rc.left + rcCorners.left;
                    rcDest.top = rc.top + rcCorners.top;
                    rcDest.right = rc.right - rc.left - rcCorners.left - rcCorners.right;
                    rcDest.bottom = rc.bottom - rc.top - rcCorners.top - rcCorners.bottom;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        if( !xtiled && !ytiled ) {
                            rcDest.right -= rcDest.left;
                            rcDest.bottom -= rcDest.top;
                            ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                                rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, \
                                rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right, \
                                rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom, SRCCOPY);
                        }
                        else if( xtiled && ytiled ) {
                            LONG lWidth = rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right;
                            LONG lHeight = rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom;
                            int iTimesX = (rcDest.right - rcDest.left + lWidth - 1) / lWidth;
                            int iTimesY = (rcDest.bottom - rcDest.top + lHeight - 1) / lHeight;
                            for( int j = 0; j < iTimesY; ++j ) {
                                LONG lDestTop = rcDest.top + lHeight * j;
                                LONG lDestBottom = rcDest.top + lHeight * (j + 1);
                                LONG lDrawHeight = lHeight;
                                if( lDestBottom > rcDest.bottom ) {
                                    lDrawHeight -= lDestBottom - rcDest.bottom;
                                    lDestBottom = rcDest.bottom;
                                }
                                for( int i = 0; i < iTimesX; ++i ) {
                                    LONG lDestLeft = rcDest.left + lWidth * i;
                                    LONG lDestRight = rcDest.left + lWidth * (i + 1);
                                    LONG lDrawWidth = lWidth;
                                    if( lDestRight > rcDest.right ) {
                                        lDrawWidth -= lDestRight - rcDest.right;
                                        lDestRight = rcDest.right;
                                    }
                                    ::BitBlt(hDC, rcDest.left + lWidth * i, rcDest.top + lHeight * j, \
                                        lDestRight - lDestLeft, lDestBottom - lDestTop, hCloneDC, \
                                        rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, SRCCOPY);
                                }
                            }
                        }
                        else if( xtiled ) {
                            LONG lWidth = rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right;
                            int iTimes = (rcDest.right - rcDest.left + lWidth - 1) / lWidth;
                            for( int i = 0; i < iTimes; ++i ) {
                                LONG lDestLeft = rcDest.left + lWidth * i;
                                LONG lDestRight = rcDest.left + lWidth * (i + 1);
                                LONG lDrawWidth = lWidth;
                                if( lDestRight > rcDest.right ) {
                                    lDrawWidth -= lDestRight - rcDest.right;
                                    lDestRight = rcDest.right;
                                }
                                ::StretchBlt(hDC, lDestLeft, rcDest.top, lDestRight - lDestLeft, rcDest.bottom, 
                                    hCloneDC, rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, \
                                    lDrawWidth, rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom, SRCCOPY);
                            }
                        }
                        else { // ytiled
                            LONG lHeight = rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom;
                            int iTimes = (rcDest.bottom - rcDest.top + lHeight - 1) / lHeight;
                            for( int i = 0; i < iTimes; ++i ) {
                                LONG lDestTop = rcDest.top + lHeight * i;
                                LONG lDestBottom = rcDest.top + lHeight * (i + 1);
                                LONG lDrawHeight = lHeight;
                                if( lDestBottom > rcDest.bottom ) {
                                    lDrawHeight -= lDestBottom - rcDest.bottom;
                                    lDestBottom = rcDest.bottom;
                                }
                                ::StretchBlt(hDC, rcDest.left, rcDest.top + lHeight * i, rcDest.right, lDestBottom - lDestTop, 
                                    hCloneDC, rcBmpPart.left + rcCorners.left, rcBmpPart.top + rcCorners.top, \
                                    rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right, lDrawHeight, SRCCOPY);                    
                            }
                        }
                    }
                }

                // left-top
                if( rcCorners.left > 0 && rcCorners.top > 0 ) {
                    rcDest.left = rc.left;
                    rcDest.top = rc.top;
                    rcDest.right = rcCorners.left;
                    rcDest.bottom = rcCorners.top;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.left, rcBmpPart.top, rcCorners.left, rcCorners.top, SRCCOPY);
                    }
                }
                // top
                if( rcCorners.top > 0 ) {
                    rcDest.left = rc.left + rcCorners.left;
                    rcDest.top = rc.top;
                    rcDest.right = rc.right - rc.left - rcCorners.left - rcCorners.right;
                    rcDest.bottom = rcCorners.top;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.left + rcCorners.left, rcBmpPart.top, rcBmpPart.right - rcBmpPart.left - \
                            rcCorners.left - rcCorners.right, rcCorners.top, SRCCOPY);
                    }
                }
                // right-top
                if( rcCorners.right > 0 && rcCorners.top > 0 ) {
                    rcDest.left = rc.right - rcCorners.right;
                    rcDest.top = rc.top;
                    rcDest.right = rcCorners.right;
                    rcDest.bottom = rcCorners.top;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.right - rcCorners.right, rcBmpPart.top, rcCorners.right, rcCorners.top, SRCCOPY);
                    }
                }
                // left
                if( rcCorners.left > 0 ) {
                    rcDest.left = rc.left;
                    rcDest.top = rc.top + rcCorners.top;
                    rcDest.right = rcCorners.left;
                    rcDest.bottom = rc.bottom - rc.top - rcCorners.top - rcCorners.bottom;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.left, rcBmpPart.top + rcCorners.top, rcCorners.left, rcBmpPart.bottom - \
                            rcBmpPart.top - rcCorners.top - rcCorners.bottom, SRCCOPY);
                    }
                }
                // right
                if( rcCorners.right > 0 ) {
                    rcDest.left = rc.right - rcCorners.right;
                    rcDest.top = rc.top + rcCorners.top;
                    rcDest.right = rcCorners.right;
                    rcDest.bottom = rc.bottom - rc.top - rcCorners.top - rcCorners.bottom;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.right - rcCorners.right, rcBmpPart.top + rcCorners.top, rcCorners.right, \
                            rcBmpPart.bottom - rcBmpPart.top - rcCorners.top - rcCorners.bottom, SRCCOPY);
                    }
                }
                // left-bottom
                if( rcCorners.left > 0 && rcCorners.bottom > 0 ) {
                    rcDest.left = rc.left;
                    rcDest.top = rc.bottom - rcCorners.bottom;
                    rcDest.right = rcCorners.left;
                    rcDest.bottom = rcCorners.bottom;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.left, rcBmpPart.bottom - rcCorners.bottom, rcCorners.left, rcCorners.bottom, SRCCOPY);
                    }
                }
                // bottom
                if( rcCorners.bottom > 0 ) {
                    rcDest.left = rc.left + rcCorners.left;
                    rcDest.top = rc.bottom - rcCorners.bottom;
                    rcDest.right = rc.right - rc.left - rcCorners.left - rcCorners.right;
                    rcDest.bottom = rcCorners.bottom;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.left + rcCorners.left, rcBmpPart.bottom - rcCorners.bottom, \
                            rcBmpPart.right - rcBmpPart.left - rcCorners.left - rcCorners.right, rcCorners.bottom, SRCCOPY);
                    }
                }
                // right-bottom
                if( rcCorners.right > 0 && rcCorners.bottom > 0 ) {
                    rcDest.left = rc.right - rcCorners.right;
                    rcDest.top = rc.bottom - rcCorners.bottom;
                    rcDest.right = rcCorners.right;
                    rcDest.bottom = rcCorners.bottom;
                    rcDest.right += rcDest.left;
                    rcDest.bottom += rcDest.top;
                    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
                        rcDest.right -= rcDest.left;
                        rcDest.bottom -= rcDest.top;
                        ::StretchBlt(hDC, rcDest.left, rcDest.top, rcDest.right, rcDest.bottom, hCloneDC, \
                            rcBmpPart.right - rcCorners.right, rcBmpPart.bottom - rcCorners.bottom, rcCorners.right, \
                            rcCorners.bottom, SRCCOPY);
                    }
                }
            }
        }

        ::SelectObject(hCloneDC, hOldBitmap);
        ::DeleteDC(hCloneDC);
    }

    bool CRenderEngine::DrawImageInfo(HDC hDC, CPaintManagerUI* pManager, const RECT& rcItem, const RECT& rcPaint, const TDrawInfo* pDrawInfo, HINSTANCE instance)
    {
        if( pManager == NULL || hDC == NULL || pDrawInfo == NULL ) return false;
        RECT rcDest = rcItem;
        if( pDrawInfo->rcDest.left != 0 || pDrawInfo->rcDest.top != 0 ||
            pDrawInfo->rcDest.right != 0 || pDrawInfo->rcDest.bottom != 0 ) {
                rcDest.left = rcItem.left + pDrawInfo->rcDest.left;
                rcDest.top = rcItem.top + pDrawInfo->rcDest.top;
                rcDest.right = rcItem.left + pDrawInfo->rcDest.right;
                if( rcDest.right > rcItem.right ) rcDest.right = rcItem.right;
                rcDest.bottom = rcItem.top + pDrawInfo->rcDest.bottom;
                if( rcDest.bottom > rcItem.bottom ) rcDest.bottom = rcItem.bottom;
        }
        bool bRet = DuiLib::DrawImage(hDC, pManager, rcItem, rcPaint, pDrawInfo->sImageName, pDrawInfo->sResType, rcDest, \
            pDrawInfo->rcSource, pDrawInfo->rcCorner, pDrawInfo->dwMask, pDrawInfo->uFade, pDrawInfo->bHole, pDrawInfo->bTiledX, pDrawInfo->bTiledY, instance);

        return bRet;
    }

    bool CRenderEngine::DrawImageString(HDC hDC, CPaintManagerUI* pManager, const RECT& rcItem, const RECT& rcPaint, LPCTSTR pStrImage, LPCTSTR pStrModify, HINSTANCE instance)
    {
        if ((pManager == NULL) || (hDC == NULL)) return false;
        const TDrawInfo* pDrawInfo = pManager->GetDrawInfo(pStrImage, pStrModify);
        return DrawImageInfo(hDC, pManager, rcItem, rcPaint, pDrawInfo, instance);
    }

    void CRenderEngine::DrawColor(HDC hDC, const RECT& rc, DWORD color)
    {
        if( color <= 0x00FFFFFF ) return;

        Gdiplus::Graphics graphics( hDC );
        Gdiplus::SolidBrush brush(Gdiplus::Color((LOBYTE((color)>>24)), GetBValue(color), GetGValue(color), GetRValue(color)));
        graphics.FillRectangle(&brush, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top);
    }

    void CRenderEngine::DrawGradient(HDC hDC, const RECT& rc, DWORD dwFirst, DWORD dwSecond, bool bVertical, int nSteps)
    {
        typedef BOOL (WINAPI *LPALPHABLEND)(HDC, int, int, int, int,HDC, int, int, int, int, BLENDFUNCTION);
        static LPALPHABLEND lpAlphaBlend = (LPALPHABLEND) ::GetProcAddress(::GetModuleHandle(_T("msimg32.dll")), "AlphaBlend");
        if( lpAlphaBlend == NULL ) lpAlphaBlend = AlphaBitBlt;
        typedef BOOL (WINAPI *PGradientFill)(HDC, PTRIVERTEX, ULONG, PVOID, ULONG, ULONG);
        static PGradientFill lpGradientFill = (PGradientFill) ::GetProcAddress(::GetModuleHandle(_T("msimg32.dll")), "GradientFill");

        BYTE bAlpha = (BYTE)(((dwFirst >> 24) + (dwSecond >> 24)) >> 1);
        if( bAlpha == 0 ) return;
        int cx = rc.right - rc.left;
        int cy = rc.bottom - rc.top;
        RECT rcPaint = rc;
        HDC hPaintDC = hDC;
        HBITMAP hPaintBitmap = NULL;
        HBITMAP hOldPaintBitmap = NULL;
        if( bAlpha < 255 ) {
            rcPaint.left = rcPaint.top = 0;
            rcPaint.right = cx;
            rcPaint.bottom = cy;
            hPaintDC = ::CreateCompatibleDC(hDC);
            hPaintBitmap = ::CreateCompatibleBitmap(hDC, cx, cy);
            ASSERT(hPaintDC);
            ASSERT(hPaintBitmap);
            hOldPaintBitmap = (HBITMAP) ::SelectObject(hPaintDC, hPaintBitmap);
        }
        if( lpGradientFill != NULL ) 
        {
            TRIVERTEX triv[2] = 
            {
                { rcPaint.left, rcPaint.top, 
                static_cast<COLOR16>(GetBValue(dwFirst) << 8),
                static_cast<COLOR16>(GetGValue(dwFirst) << 8),
                static_cast<COLOR16>(GetRValue(dwFirst) << 8), 0xFF00 },
                { rcPaint.right, rcPaint.bottom, 
                static_cast<COLOR16>(GetBValue(dwSecond) << 8),
                static_cast<COLOR16>(GetGValue(dwSecond) << 8),
                static_cast<COLOR16>(GetRValue(dwSecond) << 8), 0xFF00 }
            };
            GRADIENT_RECT grc = { 0, 1 };
            lpGradientFill(hPaintDC, triv, 2, &grc, 1, bVertical ? GRADIENT_FILL_RECT_V : GRADIENT_FILL_RECT_H);
        }
        else 
        {
            // Determine how many shades
            int nShift = 1;
            if( nSteps >= 64 ) nShift = 6;
            else if( nSteps >= 32 ) nShift = 5;
            else if( nSteps >= 16 ) nShift = 4;
            else if( nSteps >= 8 ) nShift = 3;
            else if( nSteps >= 4 ) nShift = 2;
            int nLines = 1 << nShift;
            for( int i = 0; i < nLines; i++ ) {
                // Do a little alpha blending
                BYTE bR = (BYTE) ((GetBValue(dwSecond) * (nLines - i) + GetBValue(dwFirst) * i) >> nShift);
                BYTE bG = (BYTE) ((GetGValue(dwSecond) * (nLines - i) + GetGValue(dwFirst) * i) >> nShift);
                BYTE bB = (BYTE) ((GetRValue(dwSecond) * (nLines - i) + GetRValue(dwFirst) * i) >> nShift);
                // ... then paint with the resulting color
                HBRUSH hBrush = ::CreateSolidBrush(RGB(bR,bG,bB));
                RECT r2 = rcPaint;
                if( bVertical ) {
                    r2.bottom = rc.bottom - ((i * (rc.bottom - rc.top)) >> nShift);
                    r2.top = rc.bottom - (((i + 1) * (rc.bottom - rc.top)) >> nShift);
                    if( (r2.bottom - r2.top) > 0 ) ::FillRect(hDC, &r2, hBrush);
                }
                else {
                    r2.left = rc.right - (((i + 1) * (rc.right - rc.left)) >> nShift);
                    r2.right = rc.right - ((i * (rc.right - rc.left)) >> nShift);
                    if( (r2.right - r2.left) > 0 ) ::FillRect(hPaintDC, &r2, hBrush);
                }
                ::DeleteObject(hBrush);
            }
        }
        if( bAlpha < 255 ) {
            BLENDFUNCTION bf = { AC_SRC_OVER, 0, bAlpha, AC_SRC_ALPHA };
            lpAlphaBlend(hDC, rc.left, rc.top, cx, cy, hPaintDC, 0, 0, cx, cy, bf);
            ::SelectObject(hPaintDC, hOldPaintBitmap);
            ::DeleteObject(hPaintBitmap);
            ::DeleteDC(hPaintDC);
        }
    }

    void CRenderEngine::DrawLine( HDC hDC, const RECT& rc, int nSize, DWORD dwPenColor,int nStyle /*= PS_SOLID*/ )
    {
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);

        LOGPEN lg;
        lg.lopnColor = RGB(GetBValue(dwPenColor), GetGValue(dwPenColor), GetRValue(dwPenColor));
        lg.lopnStyle = nStyle;
        lg.lopnWidth.x = nSize;
        HPEN hPen = CreatePenIndirect(&lg);
        HPEN hOldPen = (HPEN)::SelectObject(hDC, hPen);
        POINT ptTemp = { 0 };
        ::MoveToEx(hDC, rc.left, rc.top, &ptTemp);
        ::LineTo(hDC, rc.right, rc.bottom);
        ::SelectObject(hDC, hOldPen);
        ::DeleteObject(hPen);
    }

    void CRenderEngine::DrawRect(HDC hDC, const RECT& rc, int nSize, DWORD dwPenColor,int nStyle /*= PS_SOLID*/)
    {
#if USE_GDI_RENDER
        ASSERT(::GetObjectType(hDC) == OBJ_DC || ::GetObjectType(hDC) == OBJ_MEMDC);
        HPEN hPen = ::CreatePen(PS_SOLID | PS_INSIDEFRAME, nSize, RGB(GetBValue(dwPenColor), GetGValue(dwPenColor), GetRValue(dwPenColor)));
        HPEN hOldPen = (HPEN)::SelectObject(hDC, hPen);
        ::SelectObject(hDC, ::GetStockObject(HOLLOW_BRUSH));
        ::Rectangle(hDC, rc.left, rc.top, rc.right, rc.bottom);
        ::SelectObject(hDC, hOldPen);
        ::DeleteObject(hPen);
#else
        ASSERT(::GetObjectType(hDC) == OBJ_DC || ::GetObjectType(hDC) == OBJ_MEMDC);
        Gdiplus::Graphics graphics(hDC);
        Gdiplus::Pen pen(Gdiplus::Color(dwPenColor), (Gdiplus::REAL)nSize);
        pen.SetAlignment(Gdiplus::PenAlignmentInset);

        graphics.DrawRectangle(&pen, rc.left, rc.top, rc.right - rc.left - 1, rc.bottom - rc.top - 1);
#endif
    }

    void CRenderEngine::DrawRoundRect(HDC hDC, const RECT& rc, int nSize, int width, int height, DWORD dwPenColor,int nStyle /*= PS_SOLID*/)
    {
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
        HPEN hPen = ::CreatePen(nStyle, nSize, RGB(GetBValue(dwPenColor), GetGValue(dwPenColor), GetRValue(dwPenColor)));
        HPEN hOldPen = (HPEN)::SelectObject(hDC, hPen);
        ::SelectObject(hDC, ::GetStockObject(HOLLOW_BRUSH));
        ::RoundRect(hDC, rc.left, rc.top, rc.right, rc.bottom, width, height);
        ::SelectObject(hDC, hOldPen);
        ::DeleteObject(hPen);
    }

    void CRenderEngine::DrawText(HDC hDC, CPaintManagerUI* pManager, RECT& rc, LPCTSTR pstrText, DWORD dwTextColor, int iFont, UINT uStyle)
    {
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
        if( pstrText == NULL || pManager == NULL ) return;

        if ( pManager->IsLayered() || pManager->IsUseGdiplusText())
        {
            HFONT hOldFont = (HFONT)::SelectObject(hDC, pManager->GetFont(iFont));
            Gdiplus::Graphics graphics( hDC );
            Gdiplus::Font font(hDC, pManager->GetFont(iFont));
            Gdiplus::TextRenderingHint trh = Gdiplus::TextRenderingHintSystemDefault;
            switch(pManager->GetGdiplusTextRenderingHint()) 
            {
            case 0: {trh = Gdiplus::TextRenderingHintSystemDefault; break;}
            case 1: {trh = Gdiplus::TextRenderingHintSingleBitPerPixelGridFit; break;}
            case 2: {trh = Gdiplus::TextRenderingHintSingleBitPerPixel; break;}
            case 3: {trh = Gdiplus::TextRenderingHintAntiAliasGridFit; break;}
            case 4: {trh = Gdiplus::TextRenderingHintAntiAlias; break;}
            case 5: {trh = Gdiplus::TextRenderingHintClearTypeGridFit; break;}
            }
            graphics.SetTextRenderingHint(trh);
            graphics.SetSmoothingMode(Gdiplus::SmoothingModeHighQuality); 
            graphics.SetInterpolationMode(Gdiplus::InterpolationModeHighQualityBicubic);

            Gdiplus::RectF rectF((Gdiplus::REAL)rc.left, (Gdiplus::REAL)rc.top, (Gdiplus::REAL)(rc.right - rc.left), (Gdiplus::REAL)(rc.bottom - rc.top));
            Gdiplus::SolidBrush brush(Gdiplus::Color(254, GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

            Gdiplus::StringFormat stringFormat = Gdiplus::StringFormat::GenericTypographic();

            if ((uStyle & DT_END_ELLIPSIS) != 0) {
                stringFormat.SetTrimming(Gdiplus::StringTrimmingEllipsisCharacter);
            }

            int formatFlags = 0;
            if ((uStyle & DT_NOCLIP) != 0) {
                formatFlags |= Gdiplus::StringFormatFlagsNoClip;
            }
            if ((uStyle & DT_SINGLELINE) != 0) {
                formatFlags |= Gdiplus::StringFormatFlagsNoWrap;
            }

            stringFormat.SetFormatFlags(formatFlags);

            if ((uStyle & DT_LEFT) != 0) {
                stringFormat.SetAlignment(Gdiplus::StringAlignmentNear);
            }
            else if ((uStyle & DT_CENTER) != 0) {
                stringFormat.SetAlignment(Gdiplus::StringAlignmentCenter);
            }
            else if ((uStyle & DT_RIGHT) != 0) {
                stringFormat.SetAlignment(Gdiplus::StringAlignmentFar);
            }
            else {
                stringFormat.SetAlignment(Gdiplus::StringAlignmentNear);
            }
            stringFormat.GenericTypographic();
            if ((uStyle & DT_TOP) != 0) {
                stringFormat.SetLineAlignment(Gdiplus::StringAlignmentNear);
            }
            else if ((uStyle & DT_VCENTER) != 0) {
                stringFormat.SetLineAlignment(Gdiplus::StringAlignmentCenter);
            }
            else if ((uStyle & DT_BOTTOM) != 0) {
                stringFormat.SetLineAlignment(Gdiplus::StringAlignmentFar);
            }
            else {
                stringFormat.SetLineAlignment(Gdiplus::StringAlignmentNear);
            }
#ifdef UNICODE
            if ((uStyle & DT_CALCRECT) != 0)
            {
                Gdiplus::RectF bounds;

                graphics.MeasureString(pstrText, -1, &font, rectF, &stringFormat, &bounds);

                // MeasureString存在计算误差，这里加一像素
                rc.bottom = rc.top + (long)bounds.Height + 1;
                rc.right = rc.left + (long)bounds.Width + 1;
            }
            else
            {
                graphics.DrawString(pstrText, -1, &font, rectF, &stringFormat, &brush);
            }
#else
            DWORD dwSize = MultiByteToWideChar(CP_ACP, 0, pstrText, -1, NULL, 0);
            WCHAR * pcwszDest = new WCHAR[dwSize + 1];
            memset(pcwszDest, 0, (dwSize + 1) * sizeof(WCHAR));
            MultiByteToWideChar(CP_ACP, NULL, pstrText, -1, pcwszDest, dwSize);
            if(pcwszDest != NULL)
            {
                if ((uStyle & DT_CALCRECT) != 0)
                {
                    Gdiplus::RectF bounds;
                    graphics.MeasureString(pcwszDest, -1, &font, rectF, &stringFormat, &bounds);
                    rc.bottom = rc.top + (long)(bounds.Height * 1.06);
                    rc.right = rc.left + (long)(bounds.Width * 1.06);
                }
                else
                {
                    graphics.DrawString(pcwszDest, -1, &font, rectF, &stringFormat, &brush);
                }
                delete []pcwszDest;
            }
#endif
            ::SelectObject(hDC, hOldFont);
        }
        else
        {
            ::SetBkMode(hDC, TRANSPARENT);
            ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));
            HFONT hOldFont = (HFONT)::SelectObject(hDC, pManager->GetFont(iFont));
            int fonticonpos = CDuiString(pstrText).Find(_T("&#x"));
            if (fonticonpos != -1) {
                CDuiString strUnicode = CDuiString(pstrText).Mid(fonticonpos + 3);
                if (strUnicode.GetLength() > 4) strUnicode = strUnicode.Mid(0,4);
                if (strUnicode.Right(1).CompareNoCase(_T(" ")) == 0) {
                    strUnicode = strUnicode.Mid(0, strUnicode.GetLength() - 1);
                }
                if (strUnicode.Right(1).CompareNoCase(_T(";")) == 0) {
                    strUnicode = strUnicode.Mid(0,strUnicode.GetLength()-1);
                }
                wchar_t wch[2] = { 0 };
                wch[0] = static_cast<wchar_t>(_tcstol(strUnicode.GetData(), 0, 16));
                ::DrawTextW(hDC, wch, -1, &rc, uStyle);
            }
            else {
                ::DrawText(hDC, pstrText, -1, &rc, uStyle);
            }
            ::SelectObject(hDC, hOldFont);
        }
    }

    void CRenderEngine::DrawHtmlText(HDC hDC, CPaintManagerUI* pManager, RECT& rc, LPCTSTR pstrText, DWORD dwTextColor, RECT* prcLinks, CDuiString* sLinks, int& nLinkRects, int iFont, UINT uStyle)
    {
        // 考虑到在xml编辑器中使用<>符号不方便，可以使用{}符号代替
        // 支持标签嵌套（如<l><b>text</b></l>），但是交叉嵌套是应该避免的（如<l><b>text</l></b>）
        // The string formatter supports a kind of "mini-html" that consists of various short tags:
        //
        //   Bold:             <b>text</b>
        //   Color:            <c #xxxxxx>text</c>  where x = RGB in hex
        //   Font:             <f x>text</f>        where x = font id
        //   Italic:           <i>text</i>
        //   Image:            <i x y z>            where x = image name and y = imagelist num and z(optional) = imagelist id
        //   Link:             <a x>text</a>        where x(optional) = link content, normal like app:notepad or http:www.xxx.com
        //   NewLine           <n>                  
        //   Paragraph:        <p x>text</p>        where x = extra pixels indent in p
        //   Raw Text:         <r>text</r>
        //   Selected:         <s>text</s>
        //   Underline:        <u>text</u>
        //   X Indent:         <x i>                where i = hor indent in pixels
        //   Y Indent:         <y i>                where i = ver indent in pixels 

        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
        if( pstrText == NULL || pManager == NULL ) return;
        if( ::IsRectEmpty(&rc) ) return;

        bool bDraw = (uStyle & DT_CALCRECT) == 0;

        CStdPtrArray aFontArray(10);
        CStdPtrArray aColorArray(10);
        CStdPtrArray aPIndentArray(10);

        RECT rcClip = { 0 };
        ::GetClipBox(hDC, &rcClip);
        HRGN hOldRgn = ::CreateRectRgnIndirect(&rcClip);
        HRGN hRgn = ::CreateRectRgnIndirect(&rc);
        if( bDraw ) ::ExtSelectClipRgn(hDC, hRgn, RGN_AND);

        TFontInfo* pDefFontInfo = pManager->GetFontInfo(iFont);
        if(pDefFontInfo == NULL) {
            pDefFontInfo = pManager->GetDefaultFontInfo();
        }
        TEXTMETRIC* pTm = &pDefFontInfo->tm;
        HFONT hOldFont = (HFONT) ::SelectObject(hDC, pDefFontInfo->hFont);
        ::SetBkMode(hDC, TRANSPARENT);
        ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));
        DWORD dwBkColor = pManager->GetDefaultSelectedBkColor();
        ::SetBkColor(hDC, RGB(GetBValue(dwBkColor), GetGValue(dwBkColor), GetRValue(dwBkColor)));

        // If the drawstyle include a alignment, we'll need to first determine the text-size so
        // we can draw it at the correct position...
        if( ((uStyle & DT_CENTER) != 0 || (uStyle & DT_RIGHT) != 0 || (uStyle & DT_VCENTER) != 0 || (uStyle & DT_BOTTOM) != 0) && (uStyle & DT_CALCRECT) == 0 ) {
            RECT rcText = { 0, 0, 9999, 100 };
            int nLinks = 0;
            DrawHtmlText(hDC, pManager, rcText, pstrText, dwTextColor, NULL, NULL, nLinks, iFont, uStyle | DT_CALCRECT);
            if( (uStyle & DT_SINGLELINE) != 0 ){
                if( (uStyle & DT_CENTER) != 0 ) {
                    rc.left = rc.left + ((rc.right - rc.left) / 2) - ((rcText.right - rcText.left) / 2);
                    rc.right = rc.left + (rcText.right - rcText.left);
                }
                if( (uStyle & DT_RIGHT) != 0 ) {
                    rc.left = rc.right - (rcText.right - rcText.left);
                }
            }
            if( (uStyle & DT_VCENTER) != 0 ) {
                rc.top = rc.top + ((rc.bottom - rc.top) / 2) - ((rcText.bottom - rcText.top) / 2);
                rc.bottom = rc.top + (rcText.bottom - rcText.top);
            }
            if( (uStyle & DT_BOTTOM) != 0 ) {
                rc.top = rc.bottom - (rcText.bottom - rcText.top);
            }
        }

        bool bHoverLink = false;
        CDuiString sHoverLink;
        POINT ptMouse = pManager->GetMousePos();
        for( int i = 0; !bHoverLink && i < nLinkRects; i++ ) {
            if( ::PtInRect(prcLinks + i, ptMouse) ) {
                sHoverLink = *(CDuiString*)(sLinks + i);
                bHoverLink = true;
            }
        }

        POINT pt = { rc.left, rc.top };
        int iLinkIndex = 0;
        int cyLine = pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1);
        int cyMinHeight = 0;
        int cxMaxWidth = 0;
        POINT ptLinkStart = { 0 };
        bool bLineEnd = false;
        bool bInRaw = false;
        bool bInLink = false;
        bool bInSelected = false;
        int iLineLinkIndex = 0;

        // 排版习惯是图文底部对齐，所以每行绘制都要分两步，先计算高度，再绘制
        CStdPtrArray aLineFontArray;
        CStdPtrArray aLineColorArray;
        CStdPtrArray aLinePIndentArray;
        LPCTSTR pstrLineBegin = pstrText;
        bool bLineInRaw = false;
        bool bLineInLink = false;
        bool bLineInSelected = false;
        int cyLineHeight = 0;
        bool bLineDraw = false; // 行的第二阶段：绘制
        while( *pstrText != _T('\0') ) {
            if( pt.x >= rc.right || *pstrText == _T('\n') || bLineEnd ) {
                if( *pstrText == _T('\n') ) pstrText++;
                if( bLineEnd ) bLineEnd = false;
                if( !bLineDraw ) {
                    if( bInLink && iLinkIndex < nLinkRects ) {
                        ::SetRect(&prcLinks[iLinkIndex++], ptLinkStart.x, ptLinkStart.y, MIN(pt.x, rc.right), pt.y + cyLine);
                        CDuiString *pStr1 = (CDuiString*)(sLinks + iLinkIndex - 1);
                        CDuiString *pStr2 = (CDuiString*)(sLinks + iLinkIndex);
                        *pStr2 = *pStr1;
                    }
                    for( int i = iLineLinkIndex; i < iLinkIndex; i++ ) {
                        prcLinks[i].bottom = pt.y + cyLine;
                    }
                    if( bDraw ) {
                        bInLink = bLineInLink;
                        iLinkIndex = iLineLinkIndex;
                    }
                }
                else {
                    if( bInLink && iLinkIndex < nLinkRects ) iLinkIndex++;
                    bLineInLink = bInLink;
                    iLineLinkIndex = iLinkIndex;
                }
                if( (uStyle & DT_SINGLELINE) != 0 && (!bDraw || bLineDraw) ) break;
                if( bDraw ) bLineDraw = !bLineDraw; // !
                pt.x = rc.left;
                if( !bLineDraw ) pt.y += cyLine;
                if( pt.y > rc.bottom && bDraw ) break;
                ptLinkStart = pt;
                cyLine = pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1);
                if( pt.x >= rc.right ) break;
            }
            else if( !bInRaw && ( *pstrText == _T('<') || *pstrText == _T('{') )
                && ( pstrText[1] >= _T('a') && pstrText[1] <= _T('z') )
                && ( pstrText[2] == _T(' ') || pstrText[2] == _T('>') || pstrText[2] == _T('}') ) ) {
                    pstrText++;
                    LPCTSTR pstrNextStart = NULL;
                    switch( *pstrText ) {
                    case _T('a'):  // Link
                        {
                            pstrText++;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            if( iLinkIndex < nLinkRects && !bLineDraw ) {
                                CDuiString *pStr = (CDuiString*)(sLinks + iLinkIndex);
                                pStr->Empty();
                                while( *pstrText != _T('\0') && *pstrText != _T('>') && *pstrText != _T('}') ) {
                                    LPCTSTR pstrTemp = ::CharNext(pstrText);
                                    while( pstrText < pstrTemp) {
                                        *pStr += *pstrText++;
                                    }
                                }
                            }

                            DWORD clrColor = dwTextColor;
                            if(clrColor == 0) pManager->GetDefaultLinkFontColor();
                            if( bHoverLink && iLinkIndex < nLinkRects ) {
                                CDuiString *pStr = (CDuiString*)(sLinks + iLinkIndex);
                                if( sHoverLink == *pStr ) clrColor = pManager->GetDefaultLinkHoverFontColor();
                            }
                            //else if( prcLinks == NULL ) {
                            //    if( ::PtInRect(&rc, ptMouse) )
                            //        clrColor = pManager->GetDefaultLinkHoverFontColor();
                            //}
                            aColorArray.Add((LPVOID)clrColor);
                            ::SetTextColor(hDC,  RGB(GetBValue(clrColor), GetGValue(clrColor), GetRValue(clrColor)));
                            TFontInfo* pFontInfo = pDefFontInfo;
                            if( aFontArray.GetSize() > 0 ) pFontInfo = (TFontInfo*)aFontArray.GetAt(aFontArray.GetSize() - 1);
                            if( pFontInfo->bUnderline == false ) {
                                HFONT hFont = pManager->GetFont(pFontInfo->sFontName, pFontInfo->iSize, pFontInfo->bBold, true, pFontInfo->bItalic);
                                if( hFont == NULL ) hFont = pManager->AddFont(g_iFontID, pFontInfo->sFontName, pFontInfo->iSize, pFontInfo->bBold, true, pFontInfo->bItalic);
                                pFontInfo = pManager->GetFontInfo(hFont);
                                aFontArray.Add(pFontInfo);
                                pTm = &pFontInfo->tm;
                                ::SelectObject(hDC, pFontInfo->hFont);
                                cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                            }
                            ptLinkStart = pt;
                            bInLink = true;
                        }
                        break;
                    case _T('b'):  // Bold
                        {
                            pstrText++;
                            TFontInfo* pFontInfo = pDefFontInfo;
                            if( aFontArray.GetSize() > 0 ) pFontInfo = (TFontInfo*)aFontArray.GetAt(aFontArray.GetSize() - 1);
                            if( pFontInfo->bBold == false ) {
                                HFONT hFont = pManager->GetFont(pFontInfo->sFontName, pFontInfo->iSize, true, pFontInfo->bUnderline, pFontInfo->bItalic);
                                if( hFont == NULL ) hFont = pManager->AddFont(g_iFontID, pFontInfo->sFontName, pFontInfo->iSize, true, pFontInfo->bUnderline, pFontInfo->bItalic);
                                pFontInfo = pManager->GetFontInfo(hFont);
                                aFontArray.Add(pFontInfo);
                                pTm = &pFontInfo->tm;
                                ::SelectObject(hDC, pFontInfo->hFont);
                                cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                            }
                        }
                        break;
                    case _T('c'):  // Color
                        {
                            pstrText++;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            if( *pstrText == _T('#')) pstrText++;
                            DWORD clrColor = _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 16);
                            aColorArray.Add((LPVOID)clrColor);
                            ::SetTextColor(hDC, RGB(GetBValue(clrColor), GetGValue(clrColor), GetRValue(clrColor)));
                        }
                        break;
                    case _T('f'):  // Font
                        {
                            pstrText++;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            LPCTSTR pstrTemp = pstrText;
                            int iFont = (int) _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                            if( pstrTemp != pstrText ) {
                                TFontInfo* pFontInfo = pManager->GetFontInfo(iFont);
                                aFontArray.Add(pFontInfo);
                                pTm = &pFontInfo->tm;
                                ::SelectObject(hDC, pFontInfo->hFont);
                            }
                            else {
                                CDuiString sFontName;
                                int iFontSize = 10;
                                CDuiString sFontAttr;
                                bool bBold = false;
                                bool bUnderline = false;
                                bool bItalic = false;
                                while( *pstrText != _T('\0') && *pstrText != _T('>') && *pstrText != _T('}') && *pstrText != _T(' ') ) {
                                    pstrTemp = ::CharNext(pstrText);
                                    while( pstrText < pstrTemp) {
                                        sFontName += *pstrText++;
                                    }
                                }
                                while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                                if( isdigit(*pstrText) ) {
                                    iFontSize = (int) _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                                }
                                while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                                while( *pstrText != _T('\0') && *pstrText != _T('>') && *pstrText != _T('}') ) {
                                    pstrTemp = ::CharNext(pstrText);
                                    while( pstrText < pstrTemp) {
                                        sFontAttr += *pstrText++;
                                    }
                                }
                                sFontAttr.MakeLower();
                                if( sFontAttr.Find(_T("bold")) >= 0 ) bBold = true;
                                if( sFontAttr.Find(_T("underline")) >= 0 ) bUnderline = true;
                                if( sFontAttr.Find(_T("italic")) >= 0 ) bItalic = true;
                                HFONT hFont = pManager->GetFont(sFontName, iFontSize, bBold, bUnderline, bItalic);
                                if( hFont == NULL ) hFont = pManager->AddFont(g_iFontID, sFontName, iFontSize, bBold, bUnderline, bItalic);
                                TFontInfo* pFontInfo = pManager->GetFontInfo(hFont);
                                aFontArray.Add(pFontInfo);
                                pTm = &pFontInfo->tm;
                                ::SelectObject(hDC, pFontInfo->hFont);
                            }
                            cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                        }
                        break;
                    case _T('i'):  // Italic or Image
                        {    
                            pstrNextStart = pstrText - 1;
                            pstrText++;
                            CDuiString sImageString = pstrText;
                            int iWidth = 0;
                            int iHeight = 0;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            const TImageInfo* pImageInfo = NULL;
                            CDuiString sName;
                            while( *pstrText != _T('\0') && *pstrText != _T('>') && *pstrText != _T('}') && *pstrText != _T(' ') ) {
                                LPCTSTR pstrTemp = ::CharNext(pstrText);
                                while( pstrText < pstrTemp) {
                                    sName += *pstrText++;
                                }
                            }
                            if( sName.IsEmpty() ) { // Italic
                                pstrNextStart = NULL;
                                TFontInfo* pFontInfo = pDefFontInfo;
                                if( aFontArray.GetSize() > 0 ) pFontInfo = (TFontInfo*)aFontArray.GetAt(aFontArray.GetSize() - 1);
                                if( pFontInfo->bItalic == false ) {
                                    HFONT hFont = pManager->GetFont(pFontInfo->sFontName, pFontInfo->iSize, pFontInfo->bBold, pFontInfo->bUnderline, true);
                                    if( hFont == NULL ) hFont = pManager->AddFont(g_iFontID, pFontInfo->sFontName, pFontInfo->iSize, pFontInfo->bBold, pFontInfo->bUnderline, true);
                                    pFontInfo = pManager->GetFontInfo(hFont);
                                    aFontArray.Add(pFontInfo);
                                    pTm = &pFontInfo->tm;
                                    ::SelectObject(hDC, pFontInfo->hFont);
                                    cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                                }
                            }
                            else {
                                while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                                int iImageListNum = (int) _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                                if( iImageListNum <= 0 ) iImageListNum = 1;
                                while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                                int iImageListIndex = (int) _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                                if( iImageListIndex < 0 || iImageListIndex >= iImageListNum ) iImageListIndex = 0;

                                if( _tcsstr(sImageString.GetData(), _T("file=\'")) != NULL || _tcsstr(sImageString.GetData(), _T("res=\'")) != NULL ) {
                                    CDuiString sImageResType;
                                    CDuiString sImageName;
                                    LPCTSTR pStrImage = sImageString.GetData();
                                    CDuiString sItem;
                                    CDuiString sValue;
                                    while( *pStrImage != _T('\0') ) {
                                        sItem.Empty();
                                        sValue.Empty();
                                        while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
                                        while( *pStrImage != _T('\0') && *pStrImage != _T('=') && *pStrImage > _T(' ') ) {
                                            LPTSTR pstrTemp = ::CharNext(pStrImage);
                                            while( pStrImage < pstrTemp) {
                                                sItem += *pStrImage++;
                                            }
                                        }
                                        while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
                                        if( *pStrImage++ != _T('=') ) break;
                                        while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
                                        if( *pStrImage++ != _T('\'') ) break;
                                        while( *pStrImage != _T('\0') && *pStrImage != _T('\'') ) {
                                            LPTSTR pstrTemp = ::CharNext(pStrImage);
                                            while( pStrImage < pstrTemp) {
                                                sValue += *pStrImage++;
                                            }
                                        }
                                        if( *pStrImage++ != _T('\'') ) break;
                                        if( !sValue.IsEmpty() ) {
                                            if( sItem == _T("file") || sItem == _T("res") ) {
                                                sImageName = sValue;
                                            }
                                            else if( sItem == _T("restype") ) {
                                                sImageResType = sValue;
                                            }
                                        }
                                        if( *pStrImage++ != _T(' ') ) break;
                                    }

                                    pImageInfo = pManager->GetImageEx((LPCTSTR)sImageName, sImageResType);
                                }
                                else
                                    pImageInfo = pManager->GetImageEx((LPCTSTR)sName);

                                if( pImageInfo ) {
                                    iWidth = pImageInfo->nX;
                                    iHeight = pImageInfo->nY;
                                    if( iImageListNum > 1 ) iWidth /= iImageListNum;

                                    if( pt.x + iWidth > rc.right && pt.x > rc.left && (uStyle & DT_SINGLELINE) == 0 ) {
                                        bLineEnd = true;
                                    }
                                    else {
                                        pstrNextStart = NULL;
                                        if( bDraw && bLineDraw ) {
                                            CDuiRect rcImage(pt.x, pt.y + cyLineHeight - iHeight, pt.x + iWidth, pt.y + cyLineHeight);
                                            if( iHeight < cyLineHeight ) { 
                                                rcImage.bottom -= (cyLineHeight - iHeight) / 2;
                                                rcImage.top = rcImage.bottom -  iHeight;
                                            }
                                            CDuiRect rcBmpPart(0, 0, iWidth, iHeight);
                                            rcBmpPart.left = iWidth * iImageListIndex;
                                            rcBmpPart.right = iWidth * (iImageListIndex + 1);
                                            CDuiRect rcCorner(0, 0, 0, 0);
                                            DrawImage(hDC, pImageInfo->hBitmap, rcImage, rcImage, rcBmpPart, rcCorner, \
                                                pImageInfo->bAlpha, 255);
                                        }

                                        cyLine = MAX(iHeight, cyLine);
                                        pt.x += iWidth;
                                        cyMinHeight = pt.y + iHeight;
                                        cxMaxWidth = MAX(cxMaxWidth, pt.x);
                                    }
                                }
                                else pstrNextStart = NULL;
                            }
                        }
                        break;
                    case _T('n'):  // Newline
                        {
                            pstrText++;
                            if( (uStyle & DT_SINGLELINE) != 0 ) break;
                            bLineEnd = true;
                        }
                        break;
                    case _T('p'):  // Paragraph
                        {
                            pstrText++;
                            if( pt.x > rc.left ) bLineEnd = true;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            int cyLineExtra = (int)_tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                            aPIndentArray.Add((LPVOID)cyLineExtra);
                            cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + cyLineExtra);
                        }
                        break;
                    case _T('r'):  // Raw Text
                        {
                            pstrText++;
                            bInRaw = true;
                        }
                        break;
                    case _T('s'):  // Selected text background color
                        {
                            pstrText++;
                            bInSelected = !bInSelected;
                            if( bDraw && bLineDraw ) {
                                if( bInSelected ) ::SetBkMode(hDC, OPAQUE);
                                else ::SetBkMode(hDC, TRANSPARENT);
                            }
                        }
                        break;
                    case _T('u'):  // Underline text
                        {
                            pstrText++;
                            TFontInfo* pFontInfo = pDefFontInfo;
                            if( aFontArray.GetSize() > 0 ) pFontInfo = (TFontInfo*)aFontArray.GetAt(aFontArray.GetSize() - 1);
                            if( pFontInfo->bUnderline == false ) {
                                HFONT hFont = pManager->GetFont(pFontInfo->sFontName, pFontInfo->iSize, pFontInfo->bBold, true, pFontInfo->bItalic);
                                if( hFont == NULL ) hFont = pManager->AddFont(g_iFontID, pFontInfo->sFontName, pFontInfo->iSize, pFontInfo->bBold, true, pFontInfo->bItalic);
                                pFontInfo = pManager->GetFontInfo(hFont);
                                aFontArray.Add(pFontInfo);
                                pTm = &pFontInfo->tm;
                                ::SelectObject(hDC, pFontInfo->hFont);
                                cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                            }
                        }
                        break;
                    case _T('x'):  // X Indent
                        {
                            pstrText++;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            int iWidth = (int) _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                            pt.x += iWidth;
                            cxMaxWidth = MAX(cxMaxWidth, pt.x);
                        }
                        break;
                    case _T('y'):  // Y Indent
                        {
                            pstrText++;
                            while( *pstrText > _T('\0') && *pstrText <= _T(' ') ) pstrText = ::CharNext(pstrText);
                            cyLine = (int) _tcstol(pstrText, const_cast<LPTSTR*>(&pstrText), 10);
                        }
                        break;
                    }
                    if( pstrNextStart != NULL ) pstrText = pstrNextStart;
                    else {
                        while( *pstrText != _T('\0') && *pstrText != _T('>') && *pstrText != _T('}') ) pstrText = ::CharNext(pstrText);
                        pstrText = ::CharNext(pstrText);
                    }
            }
            else if( !bInRaw && ( *pstrText == _T('<') || *pstrText == _T('{') ) && pstrText[1] == _T('/') )
            {
                pstrText++;
                pstrText++;
                switch( *pstrText )
                {
                case _T('c'):
                    {
                        pstrText++;
                        aColorArray.Remove(aColorArray.GetSize() - 1);
                        DWORD clrColor = dwTextColor;
                        if( aColorArray.GetSize() > 0 ) clrColor = (int)aColorArray.GetAt(aColorArray.GetSize() - 1);
                        ::SetTextColor(hDC, RGB(GetBValue(clrColor), GetGValue(clrColor), GetRValue(clrColor)));
                    }
                    break;
                case _T('p'):
                    pstrText++;
                    if( pt.x > rc.left ) bLineEnd = true;
                    aPIndentArray.Remove(aPIndentArray.GetSize() - 1);
                    cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                    break;
                case _T('s'):
                    {
                        pstrText++;
                        bInSelected = !bInSelected;
                        if( bDraw && bLineDraw ) {
                            if( bInSelected ) ::SetBkMode(hDC, OPAQUE);
                            else ::SetBkMode(hDC, TRANSPARENT);
                        }
                    }
                    break;
                case _T('a'):
                    {
                        if( iLinkIndex < nLinkRects ) {
                            if( !bLineDraw ) ::SetRect(&prcLinks[iLinkIndex], ptLinkStart.x, ptLinkStart.y, MIN(pt.x, rc.right), pt.y + pTm->tmHeight + pTm->tmExternalLeading);
                            iLinkIndex++;
                        }
                        aColorArray.Remove(aColorArray.GetSize() - 1);
                        DWORD clrColor = dwTextColor;
                        if( aColorArray.GetSize() > 0 ) clrColor = (int)aColorArray.GetAt(aColorArray.GetSize() - 1);
                        ::SetTextColor(hDC, RGB(GetBValue(clrColor), GetGValue(clrColor), GetRValue(clrColor)));
                        bInLink = false;
                    }
                case _T('b'):
                case _T('f'):
                case _T('i'):
                case _T('u'):
                    {
                        pstrText++;
                        aFontArray.Remove(aFontArray.GetSize() - 1);
                        TFontInfo* pFontInfo = (TFontInfo*)aFontArray.GetAt(aFontArray.GetSize() - 1);
                        if( pFontInfo == NULL ) pFontInfo = pDefFontInfo;
                        if( pTm->tmItalic && pFontInfo->bItalic == false ) {
                            ABC abc;
                            ::GetCharABCWidths(hDC, _T(' '), _T(' '), &abc);
                            pt.x += abc.abcC / 2; // 简单修正一下斜体混排的问题, 正确做法应该是http://support.microsoft.com/kb/244798/en-us
                        }
                        pTm = &pFontInfo->tm;
                        ::SelectObject(hDC, pFontInfo->hFont);
                        cyLine = MAX(cyLine, pTm->tmHeight + pTm->tmExternalLeading + (int)aPIndentArray.GetAt(aPIndentArray.GetSize() - 1));
                    }
                    break;
                }
                while( *pstrText != _T('\0') && *pstrText != _T('>') && *pstrText != _T('}') ) pstrText = ::CharNext(pstrText);
                pstrText = ::CharNext(pstrText);
            }
            else if( !bInRaw &&  *pstrText == _T('<') && pstrText[2] == _T('>') && (pstrText[1] == _T('{')  || pstrText[1] == _T('}')) )
            {
                SIZE szSpace = { 0 };
                ::GetTextExtentPoint32(hDC, &pstrText[1], 1, &szSpace);
                if( bDraw && bLineDraw ) ::TextOut(hDC, pt.x, pt.y + cyLineHeight - pTm->tmHeight - pTm->tmExternalLeading, &pstrText[1], 1);
                pt.x += szSpace.cx;
                cxMaxWidth = MAX(cxMaxWidth, pt.x);
                pstrText++;pstrText++;pstrText++;
            }
            else if( !bInRaw &&  *pstrText == _T('{') && pstrText[2] == _T('}') && (pstrText[1] == _T('<')  || pstrText[1] == _T('>')) )
            {
                SIZE szSpace = { 0 };
                ::GetTextExtentPoint32(hDC, &pstrText[1], 1, &szSpace);
                if( bDraw && bLineDraw ) ::TextOut(hDC, pt.x,  pt.y + cyLineHeight - pTm->tmHeight - pTm->tmExternalLeading, &pstrText[1], 1);
                pt.x += szSpace.cx;
                cxMaxWidth = MAX(cxMaxWidth, pt.x);
                pstrText++;pstrText++;pstrText++;
            }
            else if( !bInRaw &&  *pstrText == _T(' ') )
            {
                SIZE szSpace = { 0 };
                ::GetTextExtentPoint32(hDC, _T(" "), 1, &szSpace);
                // Still need to paint the space because the font might have
                // underline formatting.
                if( bDraw && bLineDraw ) ::TextOut(hDC, pt.x,  pt.y + cyLineHeight - pTm->tmHeight - pTm->tmExternalLeading, _T(" "), 1);
                pt.x += szSpace.cx;
                cxMaxWidth = MAX(cxMaxWidth, pt.x);
                pstrText++;
            }
            else
            {
                POINT ptPos = pt;
                int cchChars = 0;
                int cchSize = 0;
                int cchLastGoodWord = 0;
                int cchLastGoodSize = 0;
                LPCTSTR p = pstrText;
                LPCTSTR pstrNext;
                SIZE szText = { 0 };
                if( !bInRaw && *p == _T('<') || *p == _T('{') ) p++, cchChars++, cchSize++;
                while( *p != _T('\0') && *p != _T('\n') ) {
                    // This part makes sure that we're word-wrapping if needed or providing support
                    // for DT_END_ELLIPSIS. Unfortunately the GetTextExtentPoint32() call is pretty
                    // slow when repeated so often.
                    // TODO: Rewrite and use GetTextExtentExPoint() instead!
                    if( bInRaw ) {
                        if( ( *p == _T('<') || *p == _T('{') ) && p[1] == _T('/') 
                            && p[2] == _T('r') && ( p[3] == _T('>') || p[3] == _T('}') ) ) {
                                p += 4;
                                bInRaw = false;
                                break;
                        }
                    }
                    else {
                        if( *p == _T('<') || *p == _T('{') ) break;
                    }
                    pstrNext = ::CharNext(p);
                    cchChars++;
                    cchSize += (int)(pstrNext - p);
                    szText.cx = cchChars * pTm->tmMaxCharWidth;
                    if( pt.x + szText.cx >= rc.right ) {
                        ::GetTextExtentPoint32(hDC, pstrText, cchSize, &szText);
                    }
                    if( pt.x + szText.cx > rc.right ) {
                        if( pt.x + szText.cx > rc.right && pt.x != rc.left) {
                            cchChars--;
                            cchSize -= (int)(pstrNext - p);
                        }
                        if( (uStyle & DT_WORDBREAK) != 0 && cchLastGoodWord > 0 ) {
                            cchChars = cchLastGoodWord;
                            cchSize = cchLastGoodSize;                 
                        }
                        if( (uStyle & DT_END_ELLIPSIS) != 0 && cchChars > 0 ) {
                            cchChars -= 1;
                            LPCTSTR pstrPrev = ::CharPrev(pstrText, p);
                            if( cchChars > 0 ) {
                                cchChars -= 1;
                                pstrPrev = ::CharPrev(pstrText, pstrPrev);
                                cchSize -= (int)(p - pstrPrev);
                            }
                            else 
                                cchSize -= (int)(p - pstrPrev);
                            pt.x = rc.right;
                        }
                        bLineEnd = true;
                        cxMaxWidth = MAX(cxMaxWidth, pt.x);
                        break;
                    }
                    if (!( ( p[0] >= _T('a') && p[0] <= _T('z') ) || ( p[0] >= _T('A') && p[0] <= _T('Z') ) )) {
                        cchLastGoodWord = cchChars;
                        cchLastGoodSize = cchSize;
                    }
                    if( *p == _T(' ') ) {
                        cchLastGoodWord = cchChars;
                        cchLastGoodSize = cchSize;
                    }
                    p = ::CharNext(p);
                }

                ::GetTextExtentPoint32(hDC, pstrText, cchSize, &szText);
                if( bDraw && bLineDraw ) {
                    if( (uStyle & DT_SINGLELINE) == 0 && (uStyle & DT_CENTER) != 0 ) {
                        ptPos.x += (rc.right - rc.left - szText.cx)/2;
                    }
                    else if( (uStyle & DT_SINGLELINE) == 0 && (uStyle & DT_RIGHT) != 0) {
                        ptPos.x += (rc.right - rc.left - szText.cx);
                    }
                    ::TextOut(hDC, ptPos.x, ptPos.y + cyLineHeight - pTm->tmHeight - pTm->tmExternalLeading, pstrText, cchSize);
                    if( pt.x >= rc.right && (uStyle & DT_END_ELLIPSIS) != 0 ) 
                        ::TextOut(hDC, ptPos.x + szText.cx, ptPos.y, _T("..."), 3);
                }
                pt.x += szText.cx;
                cxMaxWidth = MAX(cxMaxWidth, pt.x);
                pstrText += cchSize;
            }

            if( pt.x >= rc.right || *pstrText == _T('\n') || *pstrText == _T('\0') ) bLineEnd = true;
            if( bDraw && bLineEnd ) {
                if( !bLineDraw ) {
                    aFontArray.Resize(aLineFontArray.GetSize());
                    ::CopyMemory(aFontArray.GetData(), aLineFontArray.GetData(), aLineFontArray.GetSize() * sizeof(LPVOID));
                    aColorArray.Resize(aLineColorArray.GetSize());
                    ::CopyMemory(aColorArray.GetData(), aLineColorArray.GetData(), aLineColorArray.GetSize() * sizeof(LPVOID));
                    aPIndentArray.Resize(aLinePIndentArray.GetSize());
                    ::CopyMemory(aPIndentArray.GetData(), aLinePIndentArray.GetData(), aLinePIndentArray.GetSize() * sizeof(LPVOID));

                    cyLineHeight = cyLine;
                    pstrText = pstrLineBegin;
                    bInRaw = bLineInRaw;
                    bInSelected = bLineInSelected;

                    DWORD clrColor = dwTextColor;
                    if( aColorArray.GetSize() > 0 ) clrColor = (int)aColorArray.GetAt(aColorArray.GetSize() - 1);
                    ::SetTextColor(hDC, RGB(GetBValue(clrColor), GetGValue(clrColor), GetRValue(clrColor)));
                    TFontInfo* pFontInfo = (TFontInfo*)aFontArray.GetAt(aFontArray.GetSize() - 1);
                    if( pFontInfo == NULL ) pFontInfo = pDefFontInfo;
                    pTm = &pFontInfo->tm;
                    ::SelectObject(hDC, pFontInfo->hFont);
                    if( bInSelected ) ::SetBkMode(hDC, OPAQUE);
                }
                else {
                    aLineFontArray.Resize(aFontArray.GetSize());
                    ::CopyMemory(aLineFontArray.GetData(), aFontArray.GetData(), aFontArray.GetSize() * sizeof(LPVOID));
                    aLineColorArray.Resize(aColorArray.GetSize());
                    ::CopyMemory(aLineColorArray.GetData(), aColorArray.GetData(), aColorArray.GetSize() * sizeof(LPVOID));
                    aLinePIndentArray.Resize(aPIndentArray.GetSize());
                    ::CopyMemory(aLinePIndentArray.GetData(), aPIndentArray.GetData(), aPIndentArray.GetSize() * sizeof(LPVOID));
                    pstrLineBegin = pstrText;
                    bLineInSelected = bInSelected;
                    bLineInRaw = bInRaw;
                }
            }

            ASSERT(iLinkIndex<=nLinkRects);
        }

        nLinkRects = iLinkIndex;

        // Return size of text when requested
        if( (uStyle & DT_CALCRECT) != 0 ) {
            rc.bottom = MAX(cyMinHeight, pt.y + cyLine);
            rc.right = MIN(rc.right, cxMaxWidth);
        }

        if( bDraw ) ::SelectClipRgn(hDC, hOldRgn);
        ::DeleteObject(hOldRgn);
        ::DeleteObject(hRgn);

        ::SelectObject(hDC, hOldFont);
    }

    HBITMAP CRenderEngine::GenerateBitmap(CPaintManagerUI* pManager, RECT rc, CControlUI* pStopControl, DWORD dwFilterColor)
    {
        if (pManager == NULL) return NULL;
        int cx = rc.right - rc.left;
        int cy = rc.bottom - rc.top;

        bool bUseOffscreenBitmap = true;
        HDC hPaintDC = ::CreateCompatibleDC(pManager->GetPaintDC());
        ASSERT(hPaintDC);
        HBITMAP hPaintBitmap = NULL;
        //if (pStopControl == NULL && !pManager->IsLayered()) hPaintBitmap = pManager->Get();
        if( hPaintBitmap == NULL ) {
            bUseOffscreenBitmap = false;
            hPaintBitmap = ::CreateCompatibleBitmap(pManager->GetPaintDC(), rc.right, rc.bottom);
            ASSERT(hPaintBitmap);
        }
        HBITMAP hOldPaintBitmap = (HBITMAP) ::SelectObject(hPaintDC, hPaintBitmap);
        if (!bUseOffscreenBitmap) {
            CControlUI* pRoot = pManager->GetRoot();
            pRoot->Paint(hPaintDC, rc, pStopControl);
        }

        BITMAPINFO bmi = { 0 };
        bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        bmi.bmiHeader.biWidth = cx;
        bmi.bmiHeader.biHeight = cy;
        bmi.bmiHeader.biPlanes = 1;
        bmi.bmiHeader.biBitCount = 32;
        bmi.bmiHeader.biCompression = BI_RGB;
        bmi.bmiHeader.biSizeImage = cx * cy * sizeof(DWORD);
        LPDWORD pDest = NULL;
        HDC hCloneDC = ::CreateCompatibleDC(pManager->GetPaintDC());
        HBITMAP hBitmap = ::CreateDIBSection(pManager->GetPaintDC(), &bmi, DIB_RGB_COLORS, (LPVOID*) &pDest, NULL, 0);
        ASSERT(hCloneDC);
        ASSERT(hBitmap);
        if( hBitmap != NULL )
        {
            HBITMAP hOldBitmap = (HBITMAP) ::SelectObject(hCloneDC, hBitmap);
            ::BitBlt(hCloneDC, 0, 0, cx, cy, hPaintDC, rc.left, rc.top, SRCCOPY);
            RECT rcClone = {0, 0, cx, cy};
            if (dwFilterColor > 0x00FFFFFF) DrawColor(hCloneDC, rcClone, dwFilterColor);
            ::SelectObject(hCloneDC, hOldBitmap);
            ::DeleteDC(hCloneDC);  
            ::GdiFlush();
        }

        // Cleanup
        ::SelectObject(hPaintDC, hOldPaintBitmap);
        if (!bUseOffscreenBitmap) ::DeleteObject(hPaintBitmap);
        ::DeleteDC(hPaintDC);

        return hBitmap;
    }

    HBITMAP CRenderEngine::GenerateBitmap(CPaintManagerUI* pManager, CControlUI* pControl, RECT rc, DWORD dwFilterColor)
    {
        if (pManager == NULL || pControl == NULL) return NULL;
        int cx = rc.right - rc.left;
        int cy = rc.bottom - rc.top;

        HDC hPaintDC = ::CreateCompatibleDC(pManager->GetPaintDC());
        HBITMAP hPaintBitmap = ::CreateCompatibleBitmap(pManager->GetPaintDC(), rc.right, rc.bottom);
        ASSERT(hPaintDC);
        ASSERT(hPaintBitmap);
        HBITMAP hOldPaintBitmap = (HBITMAP) ::SelectObject(hPaintDC, hPaintBitmap);
        pControl->Paint(hPaintDC, rc, NULL);

        BITMAPINFO bmi = { 0 };
        bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        bmi.bmiHeader.biWidth = cx;
        bmi.bmiHeader.biHeight = cy;
        bmi.bmiHeader.biPlanes = 1;
        bmi.bmiHeader.biBitCount = 32;
        bmi.bmiHeader.biCompression = BI_RGB;
        bmi.bmiHeader.biSizeImage = cx * cy * sizeof(DWORD);
        LPDWORD pDest = NULL;
        HDC hCloneDC = ::CreateCompatibleDC(pManager->GetPaintDC());
        HBITMAP hBitmap = ::CreateDIBSection(pManager->GetPaintDC(), &bmi, DIB_RGB_COLORS, (LPVOID*) &pDest, NULL, 0);
        ASSERT(hCloneDC);
        ASSERT(hBitmap);
        if( hBitmap != NULL )
        {
            HBITMAP hOldBitmap = (HBITMAP) ::SelectObject(hCloneDC, hBitmap);
            ::BitBlt(hCloneDC, 0, 0, cx, cy, hPaintDC, rc.left, rc.top, SRCCOPY);
            RECT rcClone = {0, 0, cx, cy};
            if (dwFilterColor > 0x00FFFFFF) DrawColor(hCloneDC, rcClone, dwFilterColor);
            ::SelectObject(hCloneDC, hOldBitmap);
            ::DeleteDC(hCloneDC);  
            ::GdiFlush();
        }

        // Cleanup
        ::SelectObject(hPaintDC, hOldPaintBitmap);
        ::DeleteObject(hPaintBitmap);
        ::DeleteDC(hPaintDC);

        return hBitmap;
    }

    SIZE CRenderEngine::GetTextSize( HDC hDC, CPaintManagerUI* pManager , LPCTSTR pstrText, int iFont, UINT uStyle )
    {
        SIZE size = {0,0};
        ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
        if( pstrText == NULL || pManager == NULL ) return size;
        ::SetBkMode(hDC, TRANSPARENT);
        HFONT hOldFont = (HFONT)::SelectObject(hDC, pManager->GetFont(iFont));
        GetTextExtentPoint32(hDC, pstrText, _tcslen(pstrText) , &size);
        ::SelectObject(hDC, hOldFont);
        return size;
    }

    void CRenderEngine::CheckAlphaColor(DWORD& dwColor)
    {
        //RestoreAlphaColor认为0x00000000是真正的透明，其它都是GDI绘制导致的
        //所以在GDI绘制中不能用0xFF000000这个颜色值，现在处理是让它变成RGB(0,0,1)
        //RGB(0,0,1)与RGB(0,0,0)很难分出来
        if((0x00FFFFFF & dwColor) == 0)
        {
            dwColor += 1;
        }
    }

    HBITMAP CRenderEngine::CreateARGB32Bitmap(HDC hDC, int cx, int cy, BYTE** pBits)
    {
        LPBITMAPINFO lpbiSrc = NULL;
        lpbiSrc = (LPBITMAPINFO) new BYTE[sizeof(BITMAPINFOHEADER)];
        if (lpbiSrc == NULL) return NULL;

        lpbiSrc->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        lpbiSrc->bmiHeader.biWidth = cx;
        lpbiSrc->bmiHeader.biHeight = cy;
        lpbiSrc->bmiHeader.biPlanes = 1;
        lpbiSrc->bmiHeader.biBitCount = 32;
        lpbiSrc->bmiHeader.biCompression = BI_RGB;
        lpbiSrc->bmiHeader.biSizeImage = cx * cy;
        lpbiSrc->bmiHeader.biXPelsPerMeter = 0;
        lpbiSrc->bmiHeader.biYPelsPerMeter = 0;
        lpbiSrc->bmiHeader.biClrUsed = 0;
        lpbiSrc->bmiHeader.biClrImportant = 0;

        HBITMAP hBitmap = CreateDIBSection (hDC, lpbiSrc, DIB_RGB_COLORS, (void **)pBits, NULL, NULL);
        delete [] lpbiSrc;
        return hBitmap;
    }

    void CRenderEngine::AdjustImage(bool bUseHSL, TImageInfo* imageInfo, short H, short S, short L)
    {
        if( imageInfo == NULL || imageInfo->bUseHSL == false || imageInfo->hBitmap == NULL || 
            imageInfo->pBits == NULL || imageInfo->pSrcBits == NULL ) 
            return;
        if( bUseHSL == false || (H == 180 && S == 100 && L == 100)) {
            ::CopyMemory(imageInfo->pBits, imageInfo->pSrcBits, imageInfo->nX * imageInfo->nY * 4);
            return;
        }

        float fH, fS, fL;
        float S1 = S / 100.0f;
        float L1 = L / 100.0f;
        for( int i = 0; i < imageInfo->nX * imageInfo->nY; i++ ) {
            RGBtoHSL(*(DWORD*)(imageInfo->pSrcBits + i*4), &fH, &fS, &fL);
            fH += (H - 180);
            fH = fH > 0 ? fH : fH + 360; 
            fS *= S1;
            fL *= L1;
            HSLtoRGB((DWORD*)(imageInfo->pBits + i*4), fH, fS, fL);
        }
    }

} // namespace DuiLib
