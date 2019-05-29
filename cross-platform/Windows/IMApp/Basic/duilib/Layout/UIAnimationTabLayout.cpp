#include "StdAfx.h"
#include "UIAnimationTabLayout.h"

namespace DuiLib {
	IMPLEMENT_DUICONTROL(CAnimationTabLayoutUI)

	CAnimationTabLayoutUI::CAnimationTabLayoutUI() : 
		CUIAnimation( this ), 
		m_bIsVerticalDirection( false ), 
		m_nPositiveDirection( 1 ),
		m_pCurrentControl( NULL ),
		m_bControlVisibleFlag( false )
	{
	}

	LPCTSTR CAnimationTabLayoutUI::GetClass() const
	{
		return _T("AnimationTabLayoutUI");
	}

	LPVOID CAnimationTabLayoutUI::GetInterface(LPCTSTR pstrName)
	{
		if( _tcsicmp(pstrName, _T("AnimationTabLayout")) == 0 ) 
			return static_cast<CAnimationTabLayoutUI*>(this);
		return CTabLayoutUI::GetInterface(pstrName);
	}

	bool CAnimationTabLayoutUI::SelectItem( int iIndex )
	{
		if( iIndex < 0 || iIndex >= m_items.GetSize() ) return false;
		if( iIndex == m_iCurSel ) return true;
		if( iIndex > m_iCurSel ) m_nPositiveDirection = -1;
		if( iIndex < m_iCurSel ) m_nPositiveDirection = 1;

		int iOldSel = m_iCurSel;
		m_iCurSel = iIndex;
		for( int it = 0; it < m_items.GetSize(); it++ ) {
			if( it == iIndex ) {
				GetItemAt(it)->SetVisible(true);
				GetItemAt(it)->SetFocus();
				m_bControlVisibleFlag = false;
				m_pCurrentControl = static_cast<CControlUI*>(m_items[it]);
				
			}
			else GetItemAt(it)->SetVisible(false);
		}

		NeedParentUpdate();
		if( NULL != m_pCurrentControl ) m_pCurrentControl->SetVisible( false );
		AnimationSwitch();

		if( m_pManager != NULL ) {
			m_pManager->SetNextTabControl();
			m_pManager->SendNotify(this, _T("tabselect"), m_iCurSel, iOldSel);
		}
		return true;
	}

	void CAnimationTabLayoutUI::AnimationSwitch()
	{
		m_rcItemOld = m_rcItem;
		if( !m_bIsVerticalDirection )
		{
			m_rcCurPos.top = m_rcItem.top;
			m_rcCurPos.bottom = m_rcItem.bottom;
			m_rcCurPos.left = m_rcItem.left - ( m_rcItem.right - m_rcItem.left ) * m_nPositiveDirection + 52 * m_nPositiveDirection;
			m_rcCurPos.right = m_rcItem.right - ( m_rcItem.right - m_rcItem.left ) * m_nPositiveDirection+ 52 * m_nPositiveDirection;		
		}
		else
		{
			m_rcCurPos.left = m_rcItem.left;
			m_rcCurPos.right = m_rcItem.right;
			m_rcCurPos.top = m_rcItem.top - ( m_rcItem.bottom - m_rcItem.top ) * m_nPositiveDirection;
			m_rcCurPos.bottom = m_rcItem.bottom - ( m_rcItem.bottom - m_rcItem.top ) * m_nPositiveDirection;		
		}

		StopAnimation( TAB_ANIMATION_ID );
		StartAnimation( TAB_ANIMATION_ELLAPSE, TAB_ANIMATION_FRAME_COUNT, TAB_ANIMATION_ID );
	}

	void CAnimationTabLayoutUI::DoEvent(TEventUI& event)
	{
		if( event.Type == UIEVENT_TIMER ) 
		{
			OnTimer(  event.wParam );
		}
		__super::DoEvent( event );
	}

	void CAnimationTabLayoutUI::OnTimer( int nTimerID )
	{
		OnAnimationElapse( nTimerID );
	}

	void CAnimationTabLayoutUI::OnAnimationStep(INT nTotalFrame, INT nCurFrame, INT nAnimationID)
	{
		if( !m_bControlVisibleFlag ) {
			m_bControlVisibleFlag = true;
			m_pCurrentControl->SetVisible( true );
		}

		int iStepLen = 0;
		if( !m_bIsVerticalDirection )
		{
			iStepLen = ( m_rcItemOld.right - m_rcItemOld.left ) * m_nPositiveDirection / nTotalFrame;
			if( nCurFrame != nTotalFrame )
			{
				m_rcCurPos.left = m_rcCurPos.left + iStepLen;
				m_rcCurPos.right = m_rcCurPos.right +iStepLen;			
			}
			else
			{
				m_rcItem = m_rcCurPos = m_rcItemOld;
			}
		}
		else
		{
			iStepLen = ( m_rcItemOld.bottom - m_rcItemOld.top ) * m_nPositiveDirection / nTotalFrame;
			if( nCurFrame != nTotalFrame )
			{
				m_rcCurPos.top = m_rcCurPos.top + iStepLen;
				m_rcCurPos.bottom = m_rcCurPos.bottom +iStepLen;			
			}
			else
			{
				m_rcItem = m_rcCurPos = m_rcItemOld;	
			}	
		}
		SetPos(m_rcCurPos);
	}

	void CAnimationTabLayoutUI::OnAnimationStop(INT nAnimationID) 
	{
		SetPos(m_rcItemOld);
		NeedParentUpdate();
	}

	void CAnimationTabLayoutUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
	{
		if( _tcsicmp(pstrName, _T("animation_direction")) == 0 && _tcsicmp( pstrValue, _T("vertical")) == 0 ) m_bIsVerticalDirection = true; // pstrValue = "vertical" or "horizontal"
		return CTabLayoutUI::SetAttribute(pstrName, pstrValue);
	}
} // namespace DuiLib