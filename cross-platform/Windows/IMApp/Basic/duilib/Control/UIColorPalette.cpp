#include "StdAfx.h"
#include <math.h>

namespace DuiLib {
#define HSLMAX   255    /* H,L, and S vary over 0-HSLMAX */
#define RGBMAX   255    /* R,G, and B vary over 0-RGBMAX */
#define HSLUNDEFINED (HSLMAX*2/3)

    /*
    * Convert hue value to RGB
    */
    static float HueToRGB(float v1, float v2, float vH)
    {
        if (vH < 0.0f) vH += 1.0f;
        if (vH > 1.0f) vH -= 1.0f;
        if ((6.0f * vH) < 1.0f) return (v1 + (v2 - v1) * 6.0f * vH);
        if ((2.0f * vH) < 1.0f) return (v2);
        if ((3.0f * vH) < 2.0f) return (v1 + (v2 - v1) * ((2.0f / 3.0f) - vH) * 6.0f);
        return (v1);
    }

    /*
    * Convert color RGB to HSL
    * pHue HSL hue value            [0 - 1]
    * pSat HSL saturation value        [0 - 1]
    * pLue HSL luminance value        [0 - 1]
    */

    static void RGBToHSL(DWORD clr, float *pHue, float *pSat, float *pLue)
    {
        float R = (float)(GetRValue(clr) / 255.0f);  //RGB from 0 to 255
        float G = (float)(GetGValue(clr) / 255.0f);
        float B = (float)(GetBValue(clr) / 255.0f);

        float H, S, L;

        float fMin = min(R, min(G, B));        //Min. value of RGB
        float fMax = max(R, max(G, B));        //Max. value of RGB
        float fDelta = fMax - fMin;                //Delta RGB value

        L = (fMax + fMin) / 2.0f;

        if (fDelta == 0)                     //This is a gray, no chroma...
        {
            H = 0.0f;                          //HSL results from 0 to 1
            S = 0.0f;
        }
        else                                   //Chromatic data...
        {
            float del_R, del_G, del_B;

            if (L < 0.5) S = fDelta / (fMax + fMin);
            else           S = fDelta / (2.0f - fMax - fMin);

            del_R = (((fMax - R) / 6.0f) + (fDelta / 2.0f)) / fDelta;
            del_G = (((fMax - G) / 6.0f) + (fDelta / 2.0f)) / fDelta;
            del_B = (((fMax - B) / 6.0f) + (fDelta / 2.0f)) / fDelta;

            if (R == fMax) H = del_B - del_G;
            else if (G == fMax) H = (1.0f / 3.0f) + del_R - del_B;
            else if (B == fMax) H = (2.0f / 3.0f) + del_G - del_R;

            if (H < 0.0f) H += 1.0f;
            if (H > 1.0f)  H -= 1.0f;
        }

        *pHue = H;
        *pSat = S;
        *pLue = L;
    }

    /*
    * Convert color HSL to RGB
    * H HSL hue value                [0 - 1]
    * S HSL saturation value        [0 - 1]
    * L HSL luminance value            [0 - 1]
    */
    static DWORD HSLToRGB(float H, float S, float L)
    {
        BYTE R, G, B;
        float var_1, var_2;

        if (S == 0)                       //HSL from 0 to 1
        {
            R = G = B = (BYTE)(L * 255.0f);   //RGB results from 0 to 255
        }
        else
        {
            if (L < 0.5) var_2 = L * (1.0f + S);
            else           var_2 = (L + S) - (S * L);

            var_1 = 2.0f * L - var_2;

            R = (BYTE)(255.0f * HueToRGB(var_1, var_2, H + (1.0f / 3.0f)));
            G = (BYTE)(255.0f * HueToRGB(var_1, var_2, H));
            B = (BYTE)(255.0f * HueToRGB(var_1, var_2, H - (1.0f / 3.0f)));
        }

        return RGB(R, G, B);
    }

    /*
    * _HSLToRGB color HSL value to RGB
    * clr  RGB color value
    * nHue HSL hue value            [0 - 360]
    * nSat HSL saturation value        [0 - 200]
    * nLue HSL luminance value        [0 - 200]
    */
#define _HSLToRGB(h,s,l) (0xFF << 24 | HSLToRGB((float)h / 360.0f,(float)s / 200.0f,l / 200.0f))

    ///////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CColorPaletteUI)

    CColorPaletteUI::CColorPaletteUI()
        : m_uButtonState(0)
        , m_bIsInBar(false)
        , m_bIsInPallet(false)
        , m_nCurH(180)
        , m_nCurS(200)
        , m_nCurB(100)
        , m_nPalletHeight(200)
        , m_nBarHeight(10)
        , m_pBits(NULL)
    {
        memset(&m_bmInfo, 0, sizeof(m_bmInfo));

        m_hMemBitmap=NULL;
    }

    CColorPaletteUI::~CColorPaletteUI()
    {
        if (m_pBits) free(m_pBits);

        if (m_hMemBitmap) {
            ::DeleteObject(m_hMemBitmap);
        }

    }

    DWORD CColorPaletteUI::GetSelectColor()
    {
        DWORD dwColor = _HSLToRGB(m_nCurH, m_nCurS, m_nCurB);
        return 0xFF << 24 | GetRValue(dwColor) << 16 | GetGValue(dwColor) << 8 | GetBValue(dwColor);
    }

    void CColorPaletteUI::SetSelectColor(DWORD dwColor) 
    {
        float H = 0, S = 0, B = 0;
        COLORREF dwBkClr = RGB(GetBValue(dwColor),GetGValue(dwColor),GetRValue(dwColor));
        RGBToHSL(dwBkClr, &H, &S, &B);
        m_nCurH = (int)(H*360);
        m_nCurS = (int)(S*200);
        m_nCurB = (int)(B*200);
        UpdatePalletData();
        NeedUpdate();
    }

    LPCTSTR CColorPaletteUI::GetClass() const
    {
        return _T("ColorPaletteUI");
    }

    LPVOID CColorPaletteUI::GetInterface(LPCTSTR pstrName)
    {
        if (_tcscmp(pstrName, DUI_CTR_COLORPALETTE) == 0) return static_cast<CColorPaletteUI*>(this);
        return CControlUI::GetInterface(pstrName);
    }

    void CColorPaletteUI::SetPalletHeight(int nHeight)
    {
        m_nPalletHeight = nHeight;
    }
    int     CColorPaletteUI::GetPalletHeight() const
    {
        return m_nPalletHeight;
    }
    void CColorPaletteUI::SetBarHeight(int nHeight)
    {
        if (nHeight>150) {
            nHeight = 150; //限制最大高度，由于当前设计，nheight超出190，程序会因越界访问崩溃
        }
        m_nBarHeight = nHeight;
    }
    int  CColorPaletteUI::GetBarHeight() const
    {
        return m_nBarHeight;
    }

    void CColorPaletteUI::SetThumbImage(LPCTSTR pszImage)
    {
        if (m_strThumbImage != pszImage)
        {
            m_strThumbImage = pszImage;
            NeedUpdate();
        }
    }

    LPCTSTR CColorPaletteUI::GetThumbImage() const
    {
        return m_strThumbImage.GetData();
    }

    void CColorPaletteUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if (_tcscmp(pstrName, _T("palletheight")) == 0) SetPalletHeight(_ttoi(pstrValue));
        else if (_tcscmp(pstrName, _T("barheight")) == 0) SetBarHeight(_ttoi(pstrValue));
        else if (_tcscmp(pstrName, _T("thumbimage")) == 0) SetThumbImage(pstrValue);
        else CControlUI::SetAttribute(pstrName, pstrValue);
    }

    void CColorPaletteUI::DoInit()
    {
        m_MemDc = CreateCompatibleDC(GetManager()->GetPaintDC());
        m_hMemBitmap = CreateCompatibleBitmap(GetManager()->GetPaintDC(), 400, 360);
        SelectObject(m_MemDc, m_hMemBitmap);

        ::GetObject(m_hMemBitmap, sizeof(m_bmInfo), &m_bmInfo);
        DWORD dwSize = m_bmInfo.bmHeight * m_bmInfo.bmWidthBytes;
        m_pBits = (BYTE *)malloc(dwSize);
        ::GetBitmapBits(m_hMemBitmap, dwSize, m_pBits);
    }

    void CColorPaletteUI::SetPos(RECT rc, bool bNeedInvalidate)
    {
        CControlUI::SetPos(rc, bNeedInvalidate);

        m_ptLastPalletMouse.x = m_nCurH * (m_rcItem.right - m_rcItem.left) / 360 + m_rcItem.left;
        m_ptLastPalletMouse.y = (200 - m_nCurB) * m_nPalletHeight / 200 + m_rcItem.top;

        UpdatePalletData();
        UpdateBarData();
    }

    void CColorPaletteUI::DoEvent(TEventUI& event)
    {
        CControlUI::DoEvent(event);

        if (event.Type == UIEVENT_BUTTONDOWN)
        {
            if (event.ptMouse.x >= m_rcItem.left && event.ptMouse.y >= m_rcItem.top &&
                event.ptMouse.x < m_rcItem.right && event.ptMouse.y < m_rcItem.top + m_nPalletHeight)
            {
                int x = (event.ptMouse.x - m_rcItem.left) * 360 / (m_rcItem.right - m_rcItem.left);
                int y = (event.ptMouse.y - m_rcItem.top) * 200 / m_nPalletHeight;
                x = min(max(x, 0), 360);
                y = min(max(y, 0), 200);

                m_ptLastPalletMouse = event.ptMouse;
                if (m_ptLastPalletMouse.x < m_rcItem.left) m_ptLastPalletMouse.x = m_rcItem.left;
                if (m_ptLastPalletMouse.x > m_rcItem.right) m_ptLastPalletMouse.x = m_rcItem.right;
                if (m_ptLastPalletMouse.y < m_rcItem.top) m_ptLastPalletMouse.y = m_rcItem.top;
                if (m_ptLastPalletMouse.y > m_rcItem.top + m_nPalletHeight) m_ptLastPalletMouse.y = m_rcItem.top + m_nPalletHeight;

                m_nCurH = x;
                m_nCurB = 200 - y;

                m_uButtonState |= UISTATE_PUSHED;
                m_bIsInPallet = true;
                m_bIsInBar = false;

                UpdateBarData();
            }

            if (event.ptMouse.x >= m_rcItem.left && event.ptMouse.y >= m_rcItem.bottom - m_nBarHeight &&
                event.ptMouse.x < m_rcItem.right && event.ptMouse.y < m_rcItem.bottom)
            {
                m_nCurS = (event.ptMouse.x - m_rcItem.left) * 200 / (m_rcItem.right - m_rcItem.left);
                m_uButtonState |= UISTATE_PUSHED;
                m_bIsInBar = true;
                m_bIsInPallet = false;
                UpdatePalletData();
            }

            Invalidate();
            return;
        }
        if (event.Type == UIEVENT_BUTTONUP)
        {
            DWORD color=0;
            if ((m_uButtonState | UISTATE_PUSHED) && (IsEnabled()))
            {
                color = GetSelectColor();
                m_pManager->SendNotify(this, DUI_MSGTYPE_COLORCHANGED, color, 0);
            }

            m_uButtonState &= ~UISTATE_PUSHED;
            m_bIsInPallet = false;
            m_bIsInBar = false;

            Invalidate();
            return;
        }
        if (event.Type == UIEVENT_MOUSEMOVE)
        {
            if (!(m_uButtonState &UISTATE_PUSHED))
            {
                m_bIsInBar = false;
                m_bIsInPallet = false;
            }
            if (m_bIsInPallet == true)
            {
                POINT pt = event.ptMouse;
                pt.x -= m_rcItem.left;
                pt.y -= m_rcItem.top;

                if (pt.x >= 0 && pt.y >= 0 && pt.x <= m_rcItem.right && pt.y <= m_rcItem.top + m_nPalletHeight)
                {
                    int x = pt.x * 360 / (m_rcItem.right - m_rcItem.left);
                    int y = pt.y * 200 / m_nPalletHeight;
                    x = min(max(x, 0), 360);
                    y = min(max(y, 0), 200);

                    m_ptLastPalletMouse = event.ptMouse;
                    if (m_ptLastPalletMouse.x < m_rcItem.left) m_ptLastPalletMouse.x = m_rcItem.left;
                    if (m_ptLastPalletMouse.x > m_rcItem.right) m_ptLastPalletMouse.x = m_rcItem.right;
                    if (m_ptLastPalletMouse.y < m_rcItem.top) m_ptLastPalletMouse.y = m_rcItem.top;
                    if (m_ptLastPalletMouse.y >= m_rcItem.top + m_nPalletHeight) m_ptLastPalletMouse.y = m_rcItem.top + m_nPalletHeight;

                    m_nCurH = x;
                    m_nCurB = 200 - y;

                    UpdateBarData();
                }
            }
            else if (m_bIsInBar == true)
            {
                m_nCurS = (event.ptMouse.x - m_rcItem.left) * 200 / (m_rcItem.right - m_rcItem.left);
                m_nCurS = min(max(m_nCurS, 0), 200);
                UpdatePalletData();
            }

            Invalidate();
            return;
        }

    }

    void CColorPaletteUI::PaintBkColor(HDC hDC)
    {
        PaintPallet(hDC);
    }

    void CColorPaletteUI::PaintPallet(HDC hDC)
    {
        int nSaveDC = ::SaveDC(hDC);

        ::SetStretchBltMode(hDC, HALFTONE);
        //拉伸模式将内存图画到控件上
        StretchBlt(hDC, m_rcItem.left, m_rcItem.top, m_rcItem.right - m_rcItem.left, m_nPalletHeight, m_MemDc, 0, 1, 360, 200, SRCCOPY);
        StretchBlt(hDC, m_rcItem.left, m_rcItem.bottom - m_nBarHeight, m_rcItem.right - m_rcItem.left, m_nBarHeight, m_MemDc, 0, 210, 200, m_nBarHeight, SRCCOPY);

        RECT rcCurSorPaint = { m_ptLastPalletMouse.x - 4, m_ptLastPalletMouse.y - 4, m_ptLastPalletMouse.x + 4, m_ptLastPalletMouse.y + 4 };
        CRenderEngine::DrawImageString(hDC, m_pManager, rcCurSorPaint, m_rcPaint, m_strThumbImage);

        rcCurSorPaint.left = m_rcItem.left + m_nCurS * (m_rcItem.right - m_rcItem.left) / 200 - 4;
        rcCurSorPaint.right = m_rcItem.left + m_nCurS * (m_rcItem.right - m_rcItem.left) / 200 + 4;
        rcCurSorPaint.top = m_rcItem.bottom - m_nBarHeight / 2 - 4;
        rcCurSorPaint.bottom = m_rcItem.bottom - m_nBarHeight / 2 + 4;
        CRenderEngine::DrawImageString(hDC, m_pManager, rcCurSorPaint, m_rcPaint, m_strThumbImage);
        ::RestoreDC(hDC, nSaveDC);
    }

    void CColorPaletteUI::UpdatePalletData()
    {
        int x, y;
        BYTE *pPiexl;
        DWORD dwColor;
        for (y = 0; y < 200; ++y) {
            for (x = 0; x < 360; ++x) {
                pPiexl = LPBYTE(m_pBits) + ((200 - y)*m_bmInfo.bmWidthBytes) + ((x*m_bmInfo.bmBitsPixel) / 8);
                dwColor = _HSLToRGB(x, m_nCurS, y);
                if(dwColor == 0xFF000000) dwColor = 0xFF000001;
                pPiexl[0] = GetBValue(dwColor);
                pPiexl[1] = GetGValue(dwColor);
                pPiexl[2] = GetRValue(dwColor);
            }
        }

        SetBitmapBits(m_hMemBitmap, m_bmInfo.bmWidthBytes * m_bmInfo.bmHeight, m_pBits);
    }


    void CColorPaletteUI::UpdateBarData()
    {
        int x, y;
        BYTE *pPiexl;
        DWORD dwColor;
        //这里画出Bar
        for (y = 0; y < m_nBarHeight; ++y) {
            for (x = 0; x < 200; ++x) {
                pPiexl = LPBYTE(m_pBits) + ((210 + y)*m_bmInfo.bmWidthBytes) + ((x*m_bmInfo.bmBitsPixel) / 8);
                dwColor = _HSLToRGB(m_nCurH, x, m_nCurB);
                if(dwColor == 0xFF000000) dwColor = 0xFF000001;
                pPiexl[0] = GetBValue(dwColor);
                pPiexl[1] = GetGValue(dwColor);
                pPiexl[2] = GetRValue(dwColor);
            }
        }

        SetBitmapBits(m_hMemBitmap, m_bmInfo.bmWidthBytes * m_bmInfo.bmHeight, m_pBits);
    }

}