#include "StdAfx.h"
#include "UIFadeButton.h"

namespace DuiLib {
    IMPLEMENT_DUICONTROL(CFadeButtonUI)

    CFadeButtonUI::CFadeButtonUI() : CUIAnimation( &(*this) ), m_bMouseHove( FALSE ), m_bMouseLeave( FALSE )
    {
    }

    CFadeButtonUI::~CFadeButtonUI()
    {
        StopAnimation();
    }

    LPCTSTR CFadeButtonUI::GetClass() const
    {
        return _T("FadeButtonUI");
    }

    LPVOID CFadeButtonUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcscmp(pstrName, _T("FadeButton")) == 0 ) 
            return static_cast<CFadeButtonUI*>(this);
        return CButtonUI::GetInterface(pstrName);
    }

    void CFadeButtonUI::SetNormalImage(LPCTSTR pStrImage)
    {
        m_sNormalImage = pStrImage;
        m_sLastImage = m_sNormalImage;
    }

    void CFadeButtonUI::DoEvent(TEventUI& event)
    {
        if( event.Type == UIEVENT_MOUSEENTER && !IsAnimationRunning( FADE_IN_ID ) )
        {
            m_bFadeAlpha = 0;
            m_bMouseHove = TRUE;
            StopAnimation( FADE_OUT_ID );
            StartAnimation( FADE_ELLAPSE, FADE_FRAME_COUNT, FADE_IN_ID );
            Invalidate();
            return;
        }
        else if( event.Type == UIEVENT_MOUSELEAVE && !IsAnimationRunning( FADE_OUT_ID ) )
        {
            m_bFadeAlpha = 0;
            m_bMouseLeave = TRUE;
            StopAnimation(FADE_IN_ID);
            StartAnimation(FADE_ELLAPSE, FADE_FRAME_COUNT, FADE_OUT_ID);
            Invalidate();
            return;
        }
        else if( event.Type == UIEVENT_TIMER ) 
        {
            OnTimer(  event.wParam );
        }
        CButtonUI::DoEvent( event );
    }

    void CFadeButtonUI::OnTimer( int nTimerID )
    {
        OnAnimationElapse( nTimerID );
    }

    void CFadeButtonUI::PaintStatusImage(HDC hDC)
    {
        if( IsFocused() ) m_uButtonState |= UISTATE_FOCUSED;
        else m_uButtonState &= ~ UISTATE_FOCUSED;
        if( !IsEnabled() ) m_uButtonState |= UISTATE_DISABLED;
        else m_uButtonState &= ~ UISTATE_DISABLED;

        if( (m_uButtonState & UISTATE_DISABLED) != 0 ) {
            if( !m_sDisabledImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sDisabledImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_PUSHED) != 0 ) {
            if( !m_sPushedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sPushedImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_FOCUSED) != 0 ) {
            if( !m_sFocusedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sFocusedImage) ) {}
                else return;
            }
        }

        if( !m_sNormalImage.IsEmpty() ) {
            if( IsAnimationRunning(FADE_IN_ID) || IsAnimationRunning(FADE_OUT_ID)) {
                if( m_bMouseHove ) {
                    m_bMouseHove = FALSE;
                    m_sLastImage = m_sHotImage;
                    if( !DrawImage(hDC, (LPCTSTR)m_sNormalImage) ) {}
                    return;
                }

                if( m_bMouseLeave ) {
                    m_bMouseLeave = FALSE;
                    m_sLastImage = m_sNormalImage;
                    if( !DrawImage(hDC, (LPCTSTR)m_sHotImage) ) {}
                    return;
                }

                m_sOldImage = m_sNormalImage;
                m_sNewImage = m_sHotImage;
                if( IsAnimationRunning(FADE_OUT_ID) ) {
                    m_sOldImage = m_sHotImage;
                    m_sNewImage = m_sNormalImage;
                }
                CDuiString sFadeOut, sFadeIn;
                sFadeOut.Format(_T("fade='%d'"), 255 - m_bFadeAlpha);
                sFadeIn.Format(_T("fade='%d'"), m_bFadeAlpha);
                if( !DrawImage(hDC, (LPCTSTR)m_sOldImage, sFadeOut) ) {}
                if( !DrawImage(hDC, (LPCTSTR)m_sNewImage, sFadeIn) ) {}
                return;
            }
            else {
                if( m_bMouseHove ) {
                    m_bMouseHove = FALSE;
                    m_sLastImage = m_sHotImage;
                    if( !DrawImage(hDC, (LPCTSTR)m_sNormalImage) ) {}
                    return;
                }

                if( m_bMouseLeave ) {
                    m_bMouseLeave = FALSE;
                    m_sLastImage = m_sNormalImage;
                    if( !DrawImage(hDC, (LPCTSTR)m_sHotImage) ) {}
                    return;
                }

                if(m_sLastImage.IsEmpty()) m_sLastImage = m_sNormalImage;
                if( !DrawImage(hDC, (LPCTSTR)m_sLastImage) ) {}
                return;
            }
        }
    }

    void CFadeButtonUI::OnAnimationStep(INT nTotalFrame, INT nCurFrame, INT nAnimationID)
    {
        m_bFadeAlpha = (BYTE)((nCurFrame / (double)nTotalFrame) * 255);
        m_bFadeAlpha = m_bFadeAlpha == 0 ? 10 : m_bFadeAlpha;
        Invalidate();
    }

} // namespace DuiLib