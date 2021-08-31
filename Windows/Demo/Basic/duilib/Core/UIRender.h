#ifndef __UIRENDER_H__
#define __UIRENDER_H__

#pragma once

#ifdef USE_XIMAGE_EFFECT
class CxImage;
#endif
namespace DuiLib {
    /////////////////////////////////////////////////////////////////////////////////////
    //

    class UILIB_API CRenderClip
    {
    public:
        ~CRenderClip();
        RECT rcItem;
        HDC hDC;
        HRGN hRgn;
        HRGN hOldRgn;

        static void GenerateClip(HDC hDC, RECT rc, CRenderClip& clip);
        static void GenerateRoundClip(HDC hDC, RECT rc, RECT rcItem, int width, int height, CRenderClip& clip);
        static void UseOldClipBegin(HDC hDC, CRenderClip& clip);
        static void UseOldClipEnd(HDC hDC, CRenderClip& clip);
    };

    /////////////////////////////////////////////////////////////////////////////////////
    //

    class UILIB_API CRenderEngine
    {
    public:
        static DWORD AdjustColor(DWORD dwColor, short H, short S, short L);
        static HBITMAP CreateARGB32Bitmap(HDC hDC, int cx, int cy, BYTE** pBits);
        static void AdjustImage(bool bUseHSL, TImageInfo* imageInfo, short H, short S, short L);
        static TImageInfo* LoadImage(STRINGorID bitmap, LPCTSTR type = NULL, DWORD mask = 0, HINSTANCE instance = NULL);
#ifdef USE_XIMAGE_EFFECT
        static CxImage *LoadGifImageX(STRINGorID bitmap, LPCTSTR type = NULL, DWORD mask = 0);
#endif
        static void FreeImage(TImageInfo* bitmap, bool bDelete = true);
        static TImageInfo* LoadImage(LPCTSTR pStrImage, LPCTSTR type = NULL, DWORD mask = 0, HINSTANCE instance = NULL);
        static TImageInfo* LoadImage(UINT nID, LPCTSTR type = NULL, DWORD mask = 0, HINSTANCE instance = NULL);

        static Gdiplus::Image*    GdiplusLoadImage(LPCTSTR pstrPath);
        static Gdiplus::Image* GdiplusLoadImage(LPVOID pBuf, size_t dwSize);

        static bool DrawIconImageString(HDC hDC, CPaintManagerUI* pManager, const RECT& rcItem, const RECT& rcPaint, \
            LPCTSTR pStrImage, LPCTSTR pStrModify = NULL);
        static bool MakeFitIconDest(const RECT& rcControl,const CDuiSize& szIcon, const CDuiString& sAlign, RECT& rcDest);

        static void DrawText(HDC hDC, CPaintManagerUI* pManager, RECT& rc, LPCTSTR pstrText,DWORD dwTextColor, \
            int iFont, UINT uStyle, DWORD dwTextBKColor);

        static void DrawImage(HDC hDC, HBITMAP hBitmap, const RECT& rc, const RECT& rcPaint, \
            const RECT& rcBmpPart, const RECT& rcCorners, bool bAlpha, BYTE uFade = 255, 
            bool hole = false, bool xtiled = false, bool ytiled = false);

        static bool DrawImageInfo(HDC hDC, CPaintManagerUI* pManager, const RECT& rcItem, const RECT& rcPaint, const TDrawInfo* pDrawInfo, HINSTANCE instance = NULL);
        static bool DrawImageString(HDC hDC, CPaintManagerUI* pManager, const RECT& rcItem, const RECT& rcPaint, LPCTSTR pStrImage, LPCTSTR pStrModify = NULL, HINSTANCE instance = NULL);

        static void DrawColor(HDC hDC, const RECT& rc, DWORD color);
        static void DrawGradient(HDC hDC, const RECT& rc, DWORD dwFirst, DWORD dwSecond, bool bVertical, int nSteps);

        // 以下函数中的颜色参数alpha值无效
        static void DrawLine(HDC hDC, const RECT& rc, int nSize, DWORD dwPenColor,int nStyle = PS_SOLID);
        static void DrawRect(HDC hDC, const RECT& rc, int nSize, DWORD dwPenColor,int nStyle = PS_SOLID);
        static void DrawRoundRect(HDC hDC, const RECT& rc, int width, int height, int nSize, DWORD dwPenColor,int nStyle = PS_SOLID);
        static void DrawText(HDC hDC, CPaintManagerUI* pManager, RECT& rc, LPCTSTR pstrText, \
            DWORD dwTextColor, int iFont, UINT uStyle);
        static void DrawHtmlText(HDC hDC, CPaintManagerUI* pManager, RECT& rc, LPCTSTR pstrText, 
            DWORD dwTextColor, RECT* pLinks, CDuiString* sLinks, int& nLinkRects, int iFont, UINT uStyle);
        static HBITMAP GenerateBitmap(CPaintManagerUI* pManager, RECT rc, CControlUI* pStopControl = NULL, DWORD dwFilterColor = 0);
        static HBITMAP GenerateBitmap(CPaintManagerUI* pManager, CControlUI* pControl, RECT rc, DWORD dwFilterColor = 0);
        static SIZE GetTextSize(HDC hDC, CPaintManagerUI* pManager , LPCTSTR pstrText, int iFont, UINT uStyle);

        //alpha utilities
        static void CheckAlphaColor(DWORD& dwColor);
    };

} // namespace DuiLib

#endif // __UIRENDER_H__
