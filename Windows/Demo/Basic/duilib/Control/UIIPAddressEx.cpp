#include "StdAfx.h"
#include <Shlwapi.h>
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "shlwapi.lib")

namespace DuiLib
{
    IMPLEMENT_DUICONTROL(CIPAddressExUI)

        CIPAddressExUI::CIPAddressExUI()
    {
        m_nActiveSection = 0;
        SetReadOnly(true);

        m_nFirst = 0;
        m_nSecond = 0;
        m_nThird = 0;
        m_nFourth = 0;

        UpdateText();
    }

    LPCTSTR CIPAddressExUI::GetClass() const
    {
        return _T("IPAddressExUI");
    }

    LPVOID CIPAddressExUI::GetInterface(LPCTSTR pstrName)
    {
        if (_tcscmp(pstrName, DUI_CTR_IPADDRESS) == 0)
        {
            return static_cast<CIPAddressExUI*>(this);
        }

        return CEditUI::GetInterface(pstrName);
    }

    UINT CIPAddressExUI::GetControlFlags() const
    {
        if (!IsEnabled())
        {
            return CControlUI::GetControlFlags();
        }

        return UIFLAG_SETCURSOR | UIFLAG_TABSTOP;
    }

    void CIPAddressExUI::GetNumInput(TCHAR chKey)
    {
        if (chKey == 0x30 || chKey == VK_NUMPAD0) { m_chNum = '0'; }
        else if (chKey == 0x31 || chKey == VK_NUMPAD1) { m_chNum = '1'; }
        else if (chKey == 0x32 || chKey == VK_NUMPAD2) { m_chNum = '2'; }
        else if (chKey == 0x33 || chKey == VK_NUMPAD3) { m_chNum = '3'; }
        else if (chKey == 0x34 || chKey == VK_NUMPAD4) { m_chNum = '4'; }
        else if (chKey == 0x35 || chKey == VK_NUMPAD5) { m_chNum = '5'; }
        else if (chKey == 0x36 || chKey == VK_NUMPAD6) { m_chNum = '6'; }
        else if (chKey == 0x37 || chKey == VK_NUMPAD7) { m_chNum = '7'; }
        else if (chKey == 0x38 || chKey == VK_NUMPAD8) { m_chNum = '8'; }
        else if (chKey == 0x39 || chKey == VK_NUMPAD9) { m_chNum = '9'; }

        m_strNum += m_chNum;
        CharToInt();
        if ((m_strNum.GetLength() == 3) && (m_nActiveSection < 4))
        {
            m_nActiveSection++;
            m_strNum.Empty();
        }
    }

    void CIPAddressExUI::CharToInt()
    {
        TCHAR szNum[MAX_PATH] = { 0 };
        lstrcpyn(szNum, m_strNum.GetData(), MAX_PATH);

        int nSection = _ttoi(szNum);
        if (nSection <= 0)
        {
            nSection = 0;
        }
        else if (nSection > 255)
        {
            nSection = 255;
        }

        switch (m_nActiveSection)
        {
        case 1:
            m_nFirst = nSection;
            break;
        case 2:
            m_nSecond = nSection;
            break;
        case 3:
            m_nThird = nSection;
            break;
        case 4:
            m_nFourth = nSection;
            break;
        default:
            break;
        }
        UpdateText();
    }

    void CIPAddressExUI::DoEvent(TEventUI& event)
    {
        if (event.Type == UIEVENT_KILLFOCUS && IsEnabled())
        {
            m_nActiveSection = 0;
            Invalidate();
        }
        if (event.Type == UIEVENT_BUTTONDOWN || event.Type == UIEVENT_DBLCLICK || event.Type == UIEVENT_RBUTTONDOWN)
        {
            if (!IsEnabled())
            {
                return;
            }
            m_strNum.Empty();

            POINT p = event.ptMouse;
            RECT r = GetPos();
            // 判断焦点范围确定哪一段被选中
            int nFocus = (r.right - r.left) / 4;
            if (p.x - r.left <= nFocus)
            {
                m_nActiveSection = 1;
            }
            else if ((p.x - r.left > nFocus) && (p.x - r.left <= nFocus * 2))
            {
                m_nActiveSection = 2;
            }
            else if ((p.x - r.left > nFocus * 2) && (p.x - r.left <= nFocus * 3))
            {
                m_nActiveSection = 3;
            }
            else
            {
                m_nActiveSection = 4;
            }

            UpdateText();
        }
        else if (event.Type == UIEVENT_SCROLLWHEEL)
        {
            if (!IsEnabled())
            {
                return;
            }

            if (event.wParam)
            {
                DecNum();
            }
            else
            {
                IncNum();
            }
        }
        else if (event.Type == UIEVENT_KEYDOWN)
        {
            if (!IsEnabled())
            {
                return;
            }
            // 删除
            if ((event.chKey == VK_DELETE) || (event.chKey == VK_BACK))
            {
                switch (m_nActiveSection)
                {
                case 1:
                    m_nFirst = 0;
                    break;
                case 2:
                    m_nSecond = 0;
                    break;
                case 3:
                    m_nThird = 0;
                    break;
                case 4:
                    m_nFourth = 0;
                    break;
                default:
                    break;
                }

                m_strNum.Empty();
                UpdateText();
            }

            // 获取输入字符
            if ((m_nActiveSection == 1) && (event.chKey >= 0x30) && (event.chKey <= 0x39) ||
                (m_nActiveSection == 1) && (event.chKey >= VK_NUMPAD0) && (event.chKey <= VK_NUMPAD9))
            {
                GetNumInput(event.chKey);
            }
            else if ((m_nActiveSection == 2) && (event.chKey >= 0x30) && (event.chKey <= 0x39) ||
                (m_nActiveSection == 2) && (event.chKey >= VK_NUMPAD0) && (event.chKey <= VK_NUMPAD9))
            {
                GetNumInput(event.chKey);
            }
            else if ((m_nActiveSection == 3) && (event.chKey >= 0x30) && (event.chKey <= 0x39) ||
                (m_nActiveSection == 3) && (event.chKey >= VK_NUMPAD0) && (event.chKey <= VK_NUMPAD9))
            {
                GetNumInput(event.chKey);
            }
            else if ((m_nActiveSection == 4) && (event.chKey >= 0x30) && (event.chKey <= 0x39) ||
                (m_nActiveSection == 4) && (event.chKey >= VK_NUMPAD0) && (event.chKey <= VK_NUMPAD9))
            {
                GetNumInput(event.chKey);
            }

            if (event.chKey == VK_UP)
            {
                IncNum();
            }
            else if (event.chKey == VK_DOWN)
            {
                DecNum();
            }
            else if (event.chKey == VK_LEFT)
            {
                if (m_nActiveSection > 1)
                {
                    if (!m_strNum.IsEmpty())
                    {
                        CharToInt();
                        m_strNum.Empty();
                    }
                    m_nActiveSection--;
                    Invalidate();
                }
            }
            else if (event.chKey == VK_RIGHT)
            {
                if (m_nActiveSection < 4)
                {
                    if (!m_strNum.IsEmpty())
                    {
                        CharToInt();
                        m_strNum.Empty();
                    }
                    m_nActiveSection++;
                    Invalidate();
                }
            }
            else if ((event.chKey == VK_OEM_PERIOD) || (event.chKey == VK_DECIMAL))
            {
                if (m_nActiveSection < 4)
                {
                    if (!m_strNum.IsEmpty())
                    {
                        CharToInt();
                        m_strNum.Empty();
                    }
                    m_nActiveSection++;
                    Invalidate();
                }
            }
        }

        CLabelUI::DoEvent(event);
    }

    void CIPAddressExUI::PaintText(HDC hDC)
    {
        if (m_dwTextColor == 0) m_dwTextColor = m_pManager->GetDefaultFontColor();
        if (m_dwDisabledTextColor == 0) m_dwDisabledTextColor = m_pManager->GetDefaultDisabledColor();

        if (m_sText.IsEmpty()) return;

        RECT rc = m_rcItem;
        rc.left += m_rcTextPadding.left;
        rc.right -= m_rcTextPadding.right;
        rc.top += m_rcTextPadding.top;
        rc.bottom -= m_rcTextPadding.bottom;

        DWORD dwTextColor = IsEnabled() ? m_dwTextColor : m_dwDisabledTextColor;
        HFONT hOldFont = (HFONT)::SelectObject(hDC, m_pManager->GetFont(m_iFont));

        char szFirst[8] = { 0 };
        char szSecond[8] = { 0 };
        char szThird[8] = { 0 };
        char szFourth[8] = { 0 };
        char szDivide[8] = { "." };

        wsprintfA(szFirst, "%d", m_nFirst);
        wsprintfA(szSecond, "%d", m_nSecond);
        wsprintfA(szThird, "%d", m_nThird);
        wsprintfA(szFourth, "%d", m_nFourth);

        SIZE First;
        SIZE Second;
        SIZE Third;
        SIZE Fourth;
        SIZE divideSize;
        GetTextExtentPointA(hDC, szFirst, 3, &First);
        GetTextExtentPointA(hDC, szSecond, 3, &Second);
        GetTextExtentPointA(hDC, szThird, 3, &Third);
        GetTextExtentPointA(hDC, szFourth, 3, &Fourth);
        GetTextExtentPointA(hDC, szFourth, 1, &divideSize);

        ::SetBkMode(hDC, TRANSPARENT);
        ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

        //Start Test Draw point (".")
        RECT rcPoint = rc;
        RECT rcIP = rc;
        int nIPAddrWidth = rcPoint.right - rcPoint.left;
        int nPointPos = nIPAddrWidth / 4;
        for (int i = 0; i < 3; i++)
        {
            rcPoint.left += nPointPos;
            ::DrawTextA(hDC, szDivide, 1, &rcPoint, DT_SINGLELINE | m_uTextStyle | DT_NOPREFIX);
        }
        //End

        if (m_nFirst == 0 &&
            m_nSecond == 0 &&
            m_nThird == 0 &&
            m_nFourth == 0 &&
            m_nActiveSection == 0
            )
        {
            return;
        }

        int nIPPos = nPointPos / 2;
        if (1 == m_nActiveSection && IsEnabled())
        {
            ::SetBkMode(hDC, OPAQUE);
            ::SetBkColor(hDC, RGB(51, 153, 255));
            ::SetTextColor(hDC, RGB(255, 255, 255));
        }
        rcIP.left = rc.left + nIPPos;
        ::DrawTextA(hDC, szFirst, 3, &rcIP, DT_SINGLELINE | m_uTextStyle | DT_NOPREFIX);
        rc.left += nPointPos;
        ::SetBkMode(hDC, TRANSPARENT);
        ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

        if (2 == m_nActiveSection && IsEnabled())
        {
            ::SetBkMode(hDC, OPAQUE);
            ::SetBkColor(hDC, RGB(51, 153, 255));
            ::SetTextColor(hDC, RGB(255, 255, 255));
        }
        rcIP.left = rc.left + nIPPos;
        ::DrawTextA(hDC, szSecond, 3, &rcIP, DT_SINGLELINE | m_uTextStyle | DT_NOPREFIX);
        rc.left += nPointPos;
        ::SetBkMode(hDC, TRANSPARENT);
        ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

        if (3 == m_nActiveSection && IsEnabled())
        {
            ::SetBkMode(hDC, OPAQUE);
            ::SetBkColor(hDC, RGB(51, 153, 255));
            ::SetTextColor(hDC, RGB(255, 255, 255));
        }
        rcIP.left = rc.left + nIPPos;
        ::DrawTextA(hDC, szThird, 3, &rcIP, DT_SINGLELINE | m_uTextStyle | DT_NOPREFIX);
        rc.left += nPointPos;
        ::SetBkMode(hDC, TRANSPARENT);
        ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

        if (4 == m_nActiveSection && IsEnabled())
        {
            ::SetBkMode(hDC, OPAQUE);
            ::SetBkColor(hDC, RGB(51, 153, 255));
            ::SetTextColor(hDC, RGB(255, 255, 255));
        }
        rcIP.left = rc.left + nIPPos;
        ::DrawTextA(hDC, szFourth, 3, &rcIP, DT_SINGLELINE | m_uTextStyle | DT_NOPREFIX);
        ::SetBkMode(hDC, TRANSPARENT);
        ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

        ::SelectObject(hDC, hOldFont);
    }

    void CIPAddressExUI::SetIP(LPCWSTR lpIP)
    {
        static int nPos = 0;
        wstring curStr;
        while (*lpIP)
        {
            if (StrChrW(L".", *lpIP))
            {
                if (curStr.size())
                {
                    switch (nPos)
                    {
                    case 0:
                        m_nFirst = _wtoi(curStr.c_str());
                        nPos++;
                        break;
                    case 1:
                        m_nSecond = _wtoi(curStr.c_str());
                        nPos++;
                        break;
                    case 2:
                        m_nThird = _wtoi(curStr.c_str());
                        nPos++;
                        break;
                    default:
                        break;
                    }
                    curStr = L"";
                }
            }
            else
            {
                curStr += (WCHAR)(*lpIP);
            }
            lpIP++;
        }
        if (curStr.size())
        {
            m_nFourth = _wtoi(curStr.c_str());
            nPos = 0;
        }

        UpdateText();
    }

    CDuiString CIPAddressExUI::GetIP()
    {
        CDuiString strIP;
        strIP.Format(_T("%d.%d.%d.%d"), m_nFirst, m_nSecond, m_nThird, m_nFourth);
        return strIP;
    }

    void CIPAddressExUI::UpdateText()
    {
        TCHAR szIP[MAX_PATH] = { 0 };
        _stprintf(szIP, _T("%d.%d.%d.%d"), m_nFirst, m_nSecond, m_nThird, m_nFourth);
        SetText(szIP);
    }

    void CIPAddressExUI::IncNum()
    {
        if (m_nActiveSection == 1)
        {
            if (m_nFirst < 255)
            {
                m_nFirst++;
            }
        }
        else if (m_nActiveSection == 2)
        {
            if (m_nSecond < 255)
            {
                m_nSecond++;
            }
        }
        else if (m_nActiveSection == 3)
        {
            if (m_nThird < 255)
            {
                m_nThird++;
            }
        }
        else if (m_nActiveSection == 4)
        {
            if (m_nFourth < 255)
            {
                m_nFourth++;
            }
        }

        UpdateText();
    }

    void CIPAddressExUI::DecNum()
    {
        if (m_nActiveSection == 1)
        {
            if (m_nFirst > 0)
            {
                m_nFirst--;
            }

        }
        else if (m_nActiveSection == 2)
        {
            if (m_nSecond > 0)
            {
                m_nSecond--;
            }
        }
        else if (m_nActiveSection == 3)
        {
            if (m_nThird > 0)
            {
                m_nThird--;
            }
        }
        else if (m_nActiveSection == 4)
        {
            if (m_nFourth > 0)
            {
                m_nFourth--;
            }
        }

        UpdateText();
    }
}