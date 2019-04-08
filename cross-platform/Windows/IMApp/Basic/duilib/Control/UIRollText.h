#ifndef __UITEXTSCROLLH__
#define __UITEXTSCROLLH__

#pragma once

namespace DuiLib
{
	#define ROLLTEXT_LEFT		0
	#define ROLLTEXT_RIGHT		1
	#define ROLLTEXT_UP 		2
	#define ROLLTEXT_DOWN		3

	#define ROLLTEXT_TIMERID			20
	#define ROLLTEXT_TIMERID_SPAN		50U

	#define ROLLTEXT_ROLL_END			21
	#define ROLLTEXT_ROLL_END_SPAN		1000*6U

	class UILIB_API CRollTextUI : public CLabelUI
	{
		DECLARE_DUICONTROL(CRollTextUI)
	public:
		CRollTextUI(void);
		~CRollTextUI(void);

	public:
		LPCTSTR GetClass() const;
		LPVOID GetInterface(LPCTSTR pstrName);

	public:	
		virtual void PaintText(HDC hDC);
		virtual void DoEvent(TEventUI& event);
		virtual void SetPos(RECT rc);
		virtual void SetText(LPCTSTR pstrText);

	public:
		void BeginRoll(int nDirect = ROLLTEXT_RIGHT, LONG lTimeSpan = ROLLTEXT_TIMERID_SPAN, LONG lMaxTimeLimited = 60);
		void EndRoll();
		
	private:    
		int m_nStep;
		int m_nScrollPos;
		BOOL m_bUseRoll;
		int m_nRollDirection;   
		int m_nText_W_H;
	};

}	// namespace DuiLib

#endif // __UITEXTSCROLLH__