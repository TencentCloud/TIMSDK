#include "StdAfx.h"
#include "UIGroupBox.h"

namespace DuiLib
{
	IMPLEMENT_DUICONTROL(CGroupBoxUI)

	//////////////////////////////////////////////////////////////////////////
	//
	CGroupBoxUI::CGroupBoxUI(): m_uTextStyle(DT_SINGLELINE | DT_VCENTER | DT_CENTER), m_dwTextColor(0), 
		m_dwDisabledTextColor(0), m_iFont(-1)
	{
		SetInset(CDuiRect(20, 25, 20, 20));
	}

	CGroupBoxUI::~CGroupBoxUI()
	{
	}

	LPCTSTR CGroupBoxUI::GetClass() const
	{
		return _T("GroupBoxUI");
	}

	LPVOID CGroupBoxUI::GetInterface(LPCTSTR pstrName)
	{
		if( _tcsicmp(pstrName, _T("GroupBox")) == 0 ) return static_cast<CGroupBoxUI*>(this);
		return CVerticalLayoutUI::GetInterface(pstrName);
	}
	void CGroupBoxUI::SetTextColor(DWORD dwTextColor)
	{
		m_dwTextColor = dwTextColor;
		Invalidate();
	}

	DWORD CGroupBoxUI::GetTextColor() const
	{
		return m_dwTextColor;
	}
	void CGroupBoxUI::SetDisabledTextColor(DWORD dwTextColor)
	{
		m_dwDisabledTextColor = dwTextColor;
		Invalidate();
	}

	DWORD CGroupBoxUI::GetDisabledTextColor() const
	{
		return m_dwDisabledTextColor;
	}
	void CGroupBoxUI::SetFont(int index)
	{
		m_iFont = index;
		Invalidate();
	}

	int CGroupBoxUI::GetFont() const
	{
		return m_iFont;
	}
	void CGroupBoxUI::PaintText(HDC hDC)
	{
		CDuiString sText = GetText();
		if( sText.IsEmpty() ) {
			return;
		}

		if( m_dwTextColor == 0 ) m_dwTextColor = m_pManager->GetDefaultFontColor();
		if( m_dwDisabledTextColor == 0 ) m_dwDisabledTextColor = m_pManager->GetDefaultDisabledColor();
		if( sText.IsEmpty() ) return;

		CDuiRect rcText = m_rcItem;
		rcText.Deflate(5,5);
		SIZE szAvailable = { rcText.right - rcText.left, rcText.bottom - rcText.top };
		SIZE sz = CalcrectSize(szAvailable);

		//¼ÆËãÎÄ×ÖÇøÓò
		rcText.left = rcText.left + 15;
		rcText.top = rcText.top - 5;
		rcText.right = rcText.left + sz.cx;
		rcText.bottom = rcText.top + sz.cy;

		DWORD dwTextColor = m_dwTextColor;
		if(!IsEnabled()) dwTextColor = m_dwDisabledTextColor;
		CRenderEngine::DrawText(hDC, m_pManager, rcText, sText, dwTextColor, m_iFont, m_uTextStyle, GetAdjustColor(m_dwBackColor));
	}
	void CGroupBoxUI::PaintBorder(HDC hDC)
	{
		int nBorderSize;
		SIZE cxyBorderRound;
		RECT rcBorderSize;
		if (m_pManager) {
			nBorderSize = GetManager()->GetDPIObj()->Scale(m_nBorderSize);
			cxyBorderRound = GetManager()->GetDPIObj()->Scale(m_cxyBorderRound);
			rcBorderSize = GetManager()->GetDPIObj()->Scale(m_rcBorderSize);
		}
		else {
			nBorderSize = m_nBorderSize;
			cxyBorderRound = m_cxyBorderRound;
			rcBorderSize = m_rcBorderSize;
		}

		if( nBorderSize > 0 )
		{
			CDuiRect rcItem = m_rcItem;
			rcItem.Deflate(5, 5);
			
			if( cxyBorderRound.cx > 0 || cxyBorderRound.cy > 0 )//»­Ô²½Ç±ß¿ò
			{
				if (IsFocused() && m_dwFocusBorderColor != 0)
					CRenderEngine::DrawRoundRect(hDC, rcItem, nBorderSize, cxyBorderRound.cx, cxyBorderRound.cy, GetAdjustColor(m_dwFocusBorderColor));
				else
					CRenderEngine::DrawRoundRect(hDC, rcItem, nBorderSize, cxyBorderRound.cx, cxyBorderRound.cy, GetAdjustColor(m_dwBorderColor));
			}
			else
			{
				if (IsFocused() && m_dwFocusBorderColor != 0)
					CRenderEngine::DrawRect(hDC, rcItem, nBorderSize, GetAdjustColor(m_dwFocusBorderColor));
				else
					CRenderEngine::DrawRect(hDC, rcItem, nBorderSize, GetAdjustColor(m_dwBorderColor));
			}
		}

		PaintText(hDC);
	}

	SIZE CGroupBoxUI::CalcrectSize(SIZE szAvailable)
	{
		SIZE cxyFixed = GetFixedXY();
		RECT rcText = { 0, 0, MAX(szAvailable.cx, cxyFixed.cx), 20 };
		
		CDuiString sText = GetText();

		CRenderEngine::DrawText(m_pManager->GetPaintDC(), m_pManager, rcText, sText, m_dwTextColor, m_iFont, DT_CALCRECT | m_uTextStyle);
		SIZE cXY = {rcText.right - rcText.left, rcText.bottom - rcText.top};
		return cXY;
	}
	void CGroupBoxUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
	{
		if( _tcsicmp(pstrName, _T("textcolor")) == 0 ) 
		{
			if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
			LPTSTR pstr = NULL;
			DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
			SetTextColor(clrColor);
		}
		else if( _tcsicmp(pstrName, _T("disabledtextcolor")) == 0 ) 
		{
			if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
			LPTSTR pstr = NULL;
			DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
			SetDisabledTextColor(clrColor);
		}
		else if( _tcsicmp(pstrName, _T("font")) == 0 ) 
		{
			SetFont(_ttoi(pstrValue));
		}

		CVerticalLayoutUI::SetAttribute(pstrName, pstrValue);
	}
}
