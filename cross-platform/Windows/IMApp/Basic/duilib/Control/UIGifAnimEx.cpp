#include "StdAfx.h"
#ifdef USE_XIMAGE_EFFECT
#include "UIGifAnimEx.h"
#include "../../3rd/CxImage/ximage.h"
//
namespace DuiLib
{
    #define GIFANIMUIEX_EVENT_TIEM_ID    100
    IMPLEMENT_DUICONTROL(CGifAnimExUI)
    struct CGifAnimExUI::Imp
    {
        bool                m_bRealStop            ;//外部停止了
        bool                m_bLoadImg            ;//是否加载过图片
        bool                m_bTimer            ;//是否启动定时器
        bool                m_bAutoStart        ;//是否自动开始
        int                    m_nDelay            ;//循环毫秒数
        UINT                m_nFrameCount        ;//gif图片总帧数
        UINT                m_nFramePosition    ;//当前放到第几帧
        CxImage*            m_pGifImage            ;//gif对象
        CPaintManagerUI*&    m_pManager            ;
        CGifAnimExUI*            m_pOwer                ;//拥有者
        Imp(CPaintManagerUI* & pManager):m_pManager(pManager),
            m_bLoadImg(false),m_bTimer(false),
            m_nDelay(100),m_pGifImage(NULL),m_nFrameCount(0U),
            m_nFramePosition(0U),
            m_pOwer(NULL),m_bRealStop(false),m_bAutoStart(true)
        {
        }
        void SetOwer(CGifAnimExUI *pOwer)
        {
            m_pOwer = pOwer;
        }
        ~Imp()
        {
            if ( m_pGifImage != NULL )
            {
                delete m_pGifImage;
                m_pGifImage = NULL;
            }
        }
        inline void CheckLoadImage()
            {
            if(!m_bLoadImg)
                LoadGifImage();
        }
        inline bool IsLoadImage(){return m_bLoadImg;}
        virtual void LoadGifImage()
        {
            CDuiString sImag = m_pOwer->GetBkImage();
            m_bLoadImg = true;
            m_pGifImage    =    CRenderEngine::LoadGifImageX(STRINGorID(sImag),0, 0);
            if ( NULL == m_pGifImage ) return;
            m_nFrameCount    =    m_pGifImage->GetNumFrames();
            m_nFramePosition = 0;
            m_nDelay = m_pGifImage->GetFrameDelay();
            if (m_nDelay <= 0 ) 
                m_nDelay = 100;
            if(!m_bAutoStart)
                m_bRealStop = true;
            if(m_bAutoStart && m_pOwer->IsVisible())
                StartAnim();
        }
        void SetAutoStart(bool bAuto)
        {
            m_bAutoStart = bAuto;
        }
        void StartAnim()
        {
            if(!m_bTimer)
            {
                if(!IsLoadImage())
                {
                    LoadGifImage();
                    m_pOwer->Invalidate();
                }
                if(m_pGifImage)
                m_pManager->SetTimer( m_pOwer, GIFANIMUIEX_EVENT_TIEM_ID, m_nDelay );
                m_bTimer = true;
            }
        }
        void StopAnim(bool bGoFirstFrame)//bGoFirstFrame 是否跑到第一帧
        {
            if(m_bTimer)
            {
                if(bGoFirstFrame)
                {
                    m_nFramePosition = 0U;
                    m_pOwer->Invalidate();
                }
                m_pManager->KillTimer( m_pOwer, GIFANIMUIEX_EVENT_TIEM_ID );
                m_bTimer = false;
            }
        }
        void EventOnTimer(const WPARAM idEvent )
        {
            if ( idEvent != GIFANIMUIEX_EVENT_TIEM_ID )
                return;
            ++m_nFramePosition;
            if(m_nFramePosition >= m_nFrameCount)
                m_nFramePosition = 0;
            if(!m_pOwer->IsVisible())return;
            m_pOwer->Invalidate();
        }
        void DrawFrame( HDC hDC,const RECT& rcPaint,const RECT &rcItem)
        {
            if ( NULL == hDC || NULL == m_pGifImage ) return;
            if(m_pGifImage)
            {
                if (CxImage* pImage = m_pGifImage->GetFrame(m_nFramePosition))
                    pImage->Draw2(hDC,rcItem);
            }
        }
        void EventSetVisible(bool bVisible)
        {
            if(bVisible)
            {
                if(!m_bRealStop)
                    StartAnim();
            }
            else
                StopAnim(true);
        }
    };
    CGifAnimExUI::CGifAnimExUI(void):m_pImp(new CGifAnimExUI::Imp(m_pManager))
    {
        this;
        m_pImp->SetOwer(this);
    }
    CGifAnimExUI::~CGifAnimExUI(void)
    {
        m_pImp->StopAnim(false);
        delete m_pImp;
        m_pImp = nullptr;
    }
    LPCTSTR CGifAnimExUI::GetClass() const
    {
        return _T("GifAnimUI");
    }
    LPVOID CGifAnimExUI::GetInterface( LPCTSTR pstrName )
    {
            if( _tcscmp(pstrName, _T("GifAnim")) == 0 ) 
                return static_cast<CGifAnimExUI*>(this);
            return CLabelUI::GetInterface(pstrName);
    }
    void CGifAnimExUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcscmp(pstrName, _T("auto")) == 0 ) 
            m_pImp->SetAutoStart(_tcscmp(pstrValue, _T("true")) == 0);
        else
            __super::SetAttribute(pstrName, pstrValue);
    }
    void CGifAnimExUI::Init()
    {
        __super::Init();
        m_pImp->CheckLoadImage();
    }
    void CGifAnimExUI::SetVisible(bool bVisible /*= true*/)
    {
        __super::SetVisible(bVisible);
        m_pImp->EventSetVisible(bVisible);
    }
    void CGifAnimExUI::SetInternVisible(bool bVisible/* = true*/)
    {
        __super::SetInternVisible(bVisible);
        m_pImp->EventSetVisible(bVisible);
    }

    bool CGifAnimExUI::DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl)
    {
        if( !::IntersectRect( &m_rcPaint, &rcPaint, &m_rcItem ) ) return true;
        m_pImp->DrawFrame( hDC,rcPaint,m_rcItem);

        return true;
    }
    void CGifAnimExUI::DoEvent( TEventUI& event )
    {
        this;
        WPARAM nID = event.wParam;
        if( event.Type == UIEVENT_TIMER )
            m_pImp->EventOnTimer(nID);
    }
    void CGifAnimExUI::StartAnim()
    {
        m_pImp->m_bRealStop = false;
        m_pImp->StartAnim();
    }
    void CGifAnimExUI::StopAnim()
    {
        m_pImp->m_bRealStop = true;
        m_pImp->StopAnim(true);
    }
}
#endif//USE_XIMAGE_EFFECT