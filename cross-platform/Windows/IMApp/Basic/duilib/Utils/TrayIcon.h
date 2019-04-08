#ifndef __UITRAICON_H__
#define __UITRAICON_H__

#pragma once
#include <ShellAPI.h>

namespace DuiLib
{
	class UILIB_API CTrayIcon
	{
	public:
		CTrayIcon(void);
		~CTrayIcon(void);

	public:
		void CreateTrayIcon( HWND _RecvHwnd, UINT _IconIDResource, LPCTSTR _ToolTipText = NULL, UINT _Message = NULL);
		void DeleteTrayIcon();
		bool SetTooltipText(LPCTSTR _ToolTipText);
		bool SetTooltipText(UINT _IDResource);
		CDuiString GetTooltipText() const;

		bool SetIcon(HICON _Hicon);
		bool SetIcon(LPCTSTR _IconFile);
		bool SetIcon(UINT _IDResource);
		HICON GetIcon() const;
		void SetHideIcon();
		void SetShowIcon();
		void RemoveIcon();
		bool Enabled(){return m_bEnabled;};
		bool IsVisible(){return !m_bVisible;};

	private:
		bool m_bEnabled;
		bool m_bVisible;
		HWND m_hWnd;
		UINT m_uMessage;
		HICON m_hIcon;
		NOTIFYICONDATA	m_trayData;
	};
}
#endif // 

