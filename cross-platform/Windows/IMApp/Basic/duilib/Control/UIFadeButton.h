#ifndef __UIFADEBUTTON_H__
#define __UIFADEBUTTON_H__

#include "UIAnimation.h"
#pragma once

namespace DuiLib {

	class UILIB_API CFadeButtonUI : public CButtonUI, public CUIAnimation
	{
		DECLARE_DUICONTROL(CFadeButtonUI)
	public:
		CFadeButtonUI();
		virtual ~CFadeButtonUI();

		LPCTSTR GetClass() const;
		LPVOID GetInterface(LPCTSTR pstrName);
		void SetNormalImage(LPCTSTR pStrImage);

		void DoEvent(TEventUI& event);
		void OnTimer( int nTimerID );
		void PaintStatusImage(HDC hDC);

		virtual void OnAnimationStart(INT nAnimationID, BOOL bFirstLoop) {}
		virtual void OnAnimationStep(INT nTotalFrame, INT nCurFrame, INT nAnimationID);
		virtual void OnAnimationStop(INT nAnimationID) {}
		
	protected:
		CDuiString m_sOldImage;
		CDuiString m_sNewImage;
		CDuiString m_sLastImage;
		BYTE       m_bFadeAlpha;
		BOOL       m_bMouseHove;
		BOOL       m_bMouseLeave;
		enum{
			FADE_IN_ID			= 8,
			FADE_OUT_ID			= 9,
			FADE_ELLAPSE		= 10,
			FADE_FRAME_COUNT	= 30,
		};
	};

} // namespace DuiLib

#endif // __UIFADEBUTTON_H__