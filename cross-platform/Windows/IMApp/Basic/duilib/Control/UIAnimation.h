#ifndef __UIANIMATION_H__
#define __UIANIMATION_H__

#include "UIButton.h"
#pragma once

namespace DuiLib {

	class UILIB_API IUIAnimation
	{
	public:
		virtual ~IUIAnimation() { NULL; }

		virtual BOOL StartAnimation(int nElapse, int nTotalFrame, int nAnimationID = 0, BOOL bLoop = FALSE) = 0;
		virtual void StopAnimation(int nAnimationID = 0) = 0;
		virtual BOOL IsAnimationRunning(int nAnimationID) = 0;
		virtual int GetCurrentFrame(int nAnimationID = 0) = 0;
		virtual BOOL SetCurrentFrame(int nFrame, int nAnimationID = 0) = 0;

		virtual void OnAnimationStep(int nTotalFrame, int nCurFrame, int nAnimationID) = 0;
		virtual void OnAnimationStart(int nAnimationID, BOOL bFirstLoop) = 0;
		virtual void OnAnimationStop(int nAnimationID) = 0;

		virtual void OnAnimationElapse(int nAnimationID) = 0;
	};

	class UILIB_API CAnimationData
	{
	public:
		CAnimationData(int nElipse, int nFrame, int nID, BOOL bLoop)
		{
			m_bFirstLoop = TRUE;
			m_nCurFrame = 0;
			m_nElapse = nElipse;
			m_nTotalFrame = nFrame;
			m_bLoop = bLoop;
			m_nAnimationID = nID;
		}

	//protected:
	public:
		friend class CDUIAnimation;

		int m_nAnimationID;
		int m_nElapse;

		int m_nTotalFrame;
		int m_nCurFrame;

		BOOL m_bLoop;
		BOOL m_bFirstLoop;
	};

	class UILIB_API CUIAnimation: public IUIAnimation
	{
		struct Imp;
	public:
		CUIAnimation(CControlUI* pOwner);
		~CUIAnimation();

		virtual BOOL StartAnimation(int nElapse, int nTotalFrame, int nAnimationID = 0, BOOL bLoop = FALSE);
		virtual void StopAnimation(int nAnimationID = 0);
		virtual BOOL IsAnimationRunning(int nAnimationID);
		virtual int GetCurrentFrame(int nAnimationID = 0);
		virtual BOOL SetCurrentFrame(int nFrame, int nAnimationID = 0);

		virtual void OnAnimationStart(int nAnimationID, BOOL bFirstLoop) {};
		virtual void OnAnimationStep(int nTotalFrame, int nCurFrame, int nAnimationID) {};
		virtual void OnAnimationStop(int nAnimationID) {};

		virtual void OnAnimationElapse(int nAnimationID);

	protected:
		CAnimationData* GetAnimationDataByID(int nAnimationID);

	protected:
		CControlUI* m_pControl;
		Imp * m_pImp;
	};

} // namespace DuiLib

#endif // __UIANIMATION_H__