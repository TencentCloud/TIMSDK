#include "StdAfx.h"
#include "Utils.h"
#include <atlbase.h>
#include <atlconv.h>
namespace DuiLib
{

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CDuiPoint::CDuiPoint()
    {
        x = y = 0;
    }

    CDuiPoint::CDuiPoint(const POINT& src)
    {
        x = src.x;
        y = src.y;
    }

    CDuiPoint::CDuiPoint(int _x, int _y)
    {
        x = _x;
        y = _y;
    }

    CDuiPoint::CDuiPoint(LPARAM lParam)
    {
        x = GET_X_LPARAM(lParam);
        y = GET_Y_LPARAM(lParam);
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CDuiSize::CDuiSize()
    {
        cx = cy = 0;
    }

    CDuiSize::CDuiSize(const SIZE& src)
    {
        cx = src.cx;
        cy = src.cy;
    }

    CDuiSize::CDuiSize(const RECT rc)
    {
        cx = rc.right - rc.left;
        cy = rc.bottom - rc.top;
    }

    CDuiSize::CDuiSize(int _cx, int _cy)
    {
        cx = _cx;
        cy = _cy;
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CDuiRect::CDuiRect()
    {
        left = top = right = bottom = 0;
    }

    CDuiRect::CDuiRect(const RECT& src)
    {
        left = src.left;
        top = src.top;
        right = src.right;
        bottom = src.bottom;
    }

    CDuiRect::CDuiRect(int iLeft, int iTop, int iRight, int iBottom)
    {
        left = iLeft;
        top = iTop;
        right = iRight;
        bottom = iBottom;
    }

    int CDuiRect::GetWidth() const
    {
        return right - left;
    }

    int CDuiRect::GetHeight() const
    {
        return bottom - top;
    }

    void CDuiRect::Empty()
    {
        left = top = right = bottom = 0;
    }

    bool CDuiRect::IsNull() const
    {
        return (left == 0 && right == 0 && top == 0 && bottom == 0); 
    }

    void CDuiRect::Join(const RECT& rc)
    {
        if( rc.left < left ) left = rc.left;
        if( rc.top < top ) top = rc.top;
        if( rc.right > right ) right = rc.right;
        if( rc.bottom > bottom ) bottom = rc.bottom;
    }

    void CDuiRect::ResetOffset()
    {
        ::OffsetRect(this, -left, -top);
    }

    void CDuiRect::Normalize()
    {
        if( left > right ) { int iTemp = left; left = right; right = iTemp; }
        if( top > bottom ) { int iTemp = top; top = bottom; bottom = iTemp; }
    }

    void CDuiRect::Offset(int cx, int cy)
    {
        ::OffsetRect(this, cx, cy);
    }

    void CDuiRect::Inflate(int cx, int cy)
    {
        ::InflateRect(this, cx, cy);
    }

    void CDuiRect::Deflate(int cx, int cy)
    {
        ::InflateRect(this, -cx, -cy);
    }

    void CDuiRect::Union(CDuiRect& rc)
    {
        ::UnionRect(this, this, &rc);
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CStdPtrArray::CStdPtrArray(int iPreallocSize) : m_ppVoid(NULL), m_nCount(0), m_nAllocated(iPreallocSize)
    {
        ASSERT(iPreallocSize>=0);
        if( iPreallocSize > 0 ) m_ppVoid = static_cast<LPVOID*>(malloc(iPreallocSize * sizeof(LPVOID)));
    }

    CStdPtrArray::CStdPtrArray(const CStdPtrArray& src) : m_ppVoid(NULL), m_nCount(0), m_nAllocated(0)
    {
        for(int i=0; i<src.GetSize(); i++)
            Add(src.GetAt(i));
    }

    CStdPtrArray::~CStdPtrArray()
    {
        if( m_ppVoid != NULL ) free(m_ppVoid);
    }

    void CStdPtrArray::Empty()
    {
        if( m_ppVoid != NULL ) free(m_ppVoid);
        m_ppVoid = NULL;
        m_nCount = m_nAllocated = 0;
    }

    void CStdPtrArray::Resize(int iSize)
    {
        Empty();
        m_ppVoid = static_cast<LPVOID*>(malloc(iSize * sizeof(LPVOID)));
        ::ZeroMemory(m_ppVoid, iSize * sizeof(LPVOID));
        m_nAllocated = iSize;
        m_nCount = iSize;
    }

    bool CStdPtrArray::IsEmpty() const
    {
        return m_nCount == 0;
    }

    bool CStdPtrArray::Add(LPVOID pData)
    {
        if( ++m_nCount >= m_nAllocated) {
            int nAllocated = m_nAllocated * 2;
            if( nAllocated == 0 ) nAllocated = 11;
            LPVOID* ppVoid = static_cast<LPVOID*>(realloc(m_ppVoid, nAllocated * sizeof(LPVOID)));
            if( ppVoid != NULL ) {
                m_nAllocated = nAllocated;
                m_ppVoid = ppVoid;
            }
            else {
                --m_nCount;
                return false;
            }
        }
        m_ppVoid[m_nCount - 1] = pData;
        return true;
    }

    bool CStdPtrArray::InsertAt(int iIndex, LPVOID pData)
    {
        if( iIndex == m_nCount ) return Add(pData);
        if( iIndex < 0 || iIndex > m_nCount ) return false;
        if( ++m_nCount >= m_nAllocated) {
            int nAllocated = m_nAllocated * 2;
            if( nAllocated == 0 ) nAllocated = 11;
            LPVOID* ppVoid = static_cast<LPVOID*>(realloc(m_ppVoid, nAllocated * sizeof(LPVOID)));
            if( ppVoid != NULL ) {
                m_nAllocated = nAllocated;
                m_ppVoid = ppVoid;
            }
            else {
                --m_nCount;
                return false;
            }
        }
        memmove(&m_ppVoid[iIndex + 1], &m_ppVoid[iIndex], (m_nCount - iIndex - 1) * sizeof(LPVOID));
        m_ppVoid[iIndex] = pData;
        return true;
    }

    bool CStdPtrArray::SetAt(int iIndex, LPVOID pData)
    {
        if( iIndex < 0 || iIndex >= m_nCount ) return false;
        m_ppVoid[iIndex] = pData;
        return true;
    }

    bool CStdPtrArray::Remove(int iIndex)
    {
        if( iIndex < 0 || iIndex >= m_nCount ) return false;
        if( iIndex < --m_nCount ) ::CopyMemory(m_ppVoid + iIndex, m_ppVoid + iIndex + 1, (m_nCount - iIndex) * sizeof(LPVOID));
        return true;
    }

    int CStdPtrArray::Find(LPVOID pData) const
    {
        for( int i = 0; i < m_nCount; i++ ) if( m_ppVoid[i] == pData ) return i;
        return -1;
    }

    int CStdPtrArray::GetSize() const
    {
        return m_nCount;
    }

    LPVOID* CStdPtrArray::GetData()
    {
        return m_ppVoid;
    }

    LPVOID CStdPtrArray::GetAt(int iIndex) const
    {
        if( iIndex < 0 || iIndex >= m_nCount ) return NULL;
        return m_ppVoid[iIndex];
    }

    LPVOID CStdPtrArray::operator[] (int iIndex) const
    {
        ASSERT(iIndex>=0 && iIndex<m_nCount);
        return m_ppVoid[iIndex];
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CStdValArray::CStdValArray(int iElementSize, int iPreallocSize /*= 0*/) : 
    m_pVoid(NULL), 
        m_nCount(0), 
        m_iElementSize(iElementSize), 
        m_nAllocated(iPreallocSize)
    {
        ASSERT(iElementSize>0);
        ASSERT(iPreallocSize>=0);
        if( iPreallocSize > 0 ) m_pVoid = static_cast<LPBYTE>(malloc(iPreallocSize * m_iElementSize));
    }

    CStdValArray::~CStdValArray()
    {
        if( m_pVoid != NULL ) free(m_pVoid);
    }

    void CStdValArray::Empty()
    {   
        m_nCount = 0;  // NOTE: We keep the memory in place
    }

    bool CStdValArray::IsEmpty() const
    {
        return m_nCount == 0;
    }

    bool CStdValArray::Add(LPCVOID pData)
    {
        if( ++m_nCount >= m_nAllocated) {
            int nAllocated = m_nAllocated * 2;
            if( nAllocated == 0 ) nAllocated = 11;
            LPBYTE pVoid = static_cast<LPBYTE>(realloc(m_pVoid, nAllocated * m_iElementSize));
            if( pVoid != NULL ) {
                m_nAllocated = nAllocated;
                m_pVoid = pVoid;
            }
            else {
                --m_nCount;
                return false;
            }
        }
        ::CopyMemory(m_pVoid + ((m_nCount - 1) * m_iElementSize), pData, m_iElementSize);
        return true;
    }

    bool CStdValArray::Remove(int iIndex)
    {
        if( iIndex < 0 || iIndex >= m_nCount ) return false;
        if( iIndex < --m_nCount ) ::CopyMemory(m_pVoid + (iIndex * m_iElementSize), m_pVoid + ((iIndex + 1) * m_iElementSize), (m_nCount - iIndex) * m_iElementSize);
        return true;
    }

    int CStdValArray::GetSize() const
    {
        return m_nCount;
    }

    LPVOID CStdValArray::GetData()
    {
        return static_cast<LPVOID>(m_pVoid);
    }

    LPVOID CStdValArray::GetAt(int iIndex) const
    {
        if( iIndex < 0 || iIndex >= m_nCount ) return NULL;
        return m_pVoid + (iIndex * m_iElementSize);
    }

    LPVOID CStdValArray::operator[] (int iIndex) const
    {
        ASSERT(iIndex>=0 && iIndex<m_nCount);
        return m_pVoid + (iIndex * m_iElementSize);
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CDuiString::CDuiString() : m_pstr(m_szBuffer)
    {
        m_szBuffer[0] = '\0';
    }

    CDuiString::CDuiString(const TCHAR ch) : m_pstr(m_szBuffer)
    {
        m_szBuffer[0] = ch;
        m_szBuffer[1] = '\0';
    }

    CDuiString::CDuiString(LPCTSTR lpsz, int nLen) : m_pstr(m_szBuffer)
    {      
        ASSERT(!::IsBadStringPtr(lpsz,-1) || lpsz==NULL);
        m_szBuffer[0] = '\0';
        Assign(lpsz, nLen);
    }

    CDuiString::CDuiString(const CDuiString& src) : m_pstr(m_szBuffer)
    {
        m_szBuffer[0] = '\0';
        Assign(src.m_pstr);
    }

    CDuiString::~CDuiString()
    {
        if( m_pstr != m_szBuffer ) free(m_pstr);
    }

    int CDuiString::GetLength() const
    { 
        return (int) _tcslen(m_pstr); 
    }

    CDuiString::operator LPCTSTR() const 
    { 
        return m_pstr; 
    }

    void CDuiString::Append(LPCTSTR pstr)
    {
        int nNewLength = GetLength() + (int) _tcslen(pstr);
        if( nNewLength >= MAX_LOCAL_STRING_LEN ) {
            if( m_pstr == m_szBuffer ) {
                m_pstr = static_cast<LPTSTR>(malloc((nNewLength + 1) * sizeof(TCHAR)));
                _tcscpy(m_pstr, m_szBuffer);
                _tcscat(m_pstr, pstr);
            }
            else {
                m_pstr = static_cast<LPTSTR>(realloc(m_pstr, (nNewLength + 1) * sizeof(TCHAR)));
                _tcscat(m_pstr, pstr);
            }
        }
        else {
            if( m_pstr != m_szBuffer ) {
                free(m_pstr);
                m_pstr = m_szBuffer;
            }
            _tcscat(m_szBuffer, pstr);
        }
    }

    void CDuiString::Assign(LPCTSTR pstr, int cchMax)
    {
        if( pstr == NULL ) pstr = _T("");
        cchMax = (cchMax < 0 ? (int) _tcslen(pstr) : cchMax);
        if( cchMax < MAX_LOCAL_STRING_LEN ) {
            if( m_pstr != m_szBuffer ) {
                free(m_pstr);
                m_pstr = m_szBuffer;
            }
        }
        else if( cchMax > GetLength() || m_pstr == m_szBuffer ) {
            if( m_pstr == m_szBuffer ) m_pstr = NULL;
            m_pstr = static_cast<LPTSTR>(realloc(m_pstr, (cchMax + 1) * sizeof(TCHAR)));
        }
        _tcsncpy(m_pstr, pstr, cchMax);
        m_pstr[cchMax] = '\0';
    }

    bool CDuiString::IsEmpty() const 
    { 
        return m_pstr[0] == '\0'; 
    }

    void CDuiString::Empty() 
    { 
        if( m_pstr != m_szBuffer ) free(m_pstr);
        m_pstr = m_szBuffer;
        m_szBuffer[0] = '\0'; 
    }

    LPCTSTR CDuiString::GetData() const
    {
        return m_pstr;
    }
    std::wstring CDuiString::GetStringW()
    {
#ifdef _UNICODE
        return GetData();
#else
        if (!this->IsEmpty()) {
            wstring nRet = CA2W(GetData());
            return nRet;
        }
        return _T("");
#endif // _UNICODE
    }

    std::string CDuiString::GetStringA()
    {
#ifdef _UNICODE
        if (!IsEmpty()) {
            string nRet = CW2A(GetData());
            return nRet;
        }
        return "";
#else
        return GetData();
#endif // _UNICODE
    }
    TCHAR CDuiString::GetAt(int nIndex) const
    {
        return m_pstr[nIndex];
    }

    TCHAR CDuiString::operator[] (int nIndex) const
    { 
        return m_pstr[nIndex];
    }   

    const CDuiString& CDuiString::operator=(const CDuiString& src)
    {      
        Assign(src);
        return *this;
    }

    const CDuiString& CDuiString::operator=(LPCTSTR lpStr)
    {      
        if ( lpStr )
        {
            ASSERT(!::IsBadStringPtr(lpStr,-1));
            Assign(lpStr);
        }
        else
        {
            Empty();
        }
        return *this;
    }

#ifdef _UNICODE

    const CDuiString& CDuiString::operator=(LPCSTR lpStr)
    {
        if ( lpStr )
        {
            ASSERT(!::IsBadStringPtrA(lpStr,-1));
            int cchStr = (int) strlen(lpStr) + 1;
            LPWSTR pwstr = (LPWSTR) malloc(cchStr*3);
            if( pwstr != NULL ) ::MultiByteToWideChar(::GetACP(), 0, lpStr, -1, pwstr, cchStr) ;
            Assign(pwstr);
            if (NULL != pwstr) free(pwstr);
        }
        else
        {
            Empty();
        }
        return *this;
    }

    const CDuiString& CDuiString::operator+=(LPCSTR lpStr)
    {
        if ( lpStr )
        {
            ASSERT(!::IsBadStringPtrA(lpStr,-1));
            int cchStr = (int) strlen(lpStr) + 1;
            LPWSTR pwstr = (LPWSTR) malloc(cchStr * 3);
            if( pwstr != NULL ) ::MultiByteToWideChar(::GetACP(), 0, lpStr, -1, pwstr, cchStr) ;
            Append(pwstr);
            if (NULL != pwstr) free(pwstr);
        }

        return *this;
    }

#else

    const CDuiString& CDuiString::operator=(LPCWSTR lpwStr)
    {      
        if ( lpwStr )
        {
            ASSERT(!::IsBadStringPtrW(lpwStr,-1));
            int cchStr = ((int) wcslen(lpwStr) * 2) + 1;
            LPSTR pstr = (LPSTR) malloc(cchStr);
            if( pstr != NULL ) ::WideCharToMultiByte(::GetACP(), 0, lpwStr, -1, pstr, cchStr, NULL, NULL);
            Assign(pstr);
            if (NULL != pwstr) free(pstr);
        }
        else
        {
            Empty();
        }

        return *this;
    }

    const CDuiString& CDuiString::operator+=(LPCWSTR lpwStr)
    {
        if ( lpwStr )
        {
            ASSERT(!::IsBadStringPtrW(lpwStr,-1));
            int cchStr = ((int) wcslen(lpwStr) * 2) + 1;
            LPSTR pstr = (LPSTR) malloc(cchStr);
            if( pstr != NULL ) ::WideCharToMultiByte(::GetACP(), 0, lpwStr, -1, pstr, cchStr, NULL, NULL);
            Append(pstr);
            if (NULL != pwstr) free(pstr);
        }

        return *this;
    }

#endif // _UNICODE

    const CDuiString& CDuiString::operator=(const TCHAR ch)
    {
        Empty();
        m_szBuffer[0] = ch;
        m_szBuffer[1] = '\0';
        return *this;
    }

    CDuiString CDuiString::operator+(const CDuiString& src) const
    {
        CDuiString sTemp = *this;
        sTemp.Append(src);
        return sTemp;
    }

    CDuiString CDuiString::operator+(LPCTSTR lpStr) const
    {
        if ( lpStr )
        {
            ASSERT(!::IsBadStringPtr(lpStr,-1));
            CDuiString sTemp = *this;
            sTemp.Append(lpStr);
            return sTemp;
        }

        return *this;
    }

    const CDuiString& CDuiString::operator+=(const CDuiString& src)
    {      
        Append(src);
        return *this;
    }

    const CDuiString& CDuiString::operator+=(LPCTSTR lpStr)
    {      
        if ( lpStr )
        {
            ASSERT(!::IsBadStringPtr(lpStr,-1));
            Append(lpStr);
        }

        return *this;
    }

    const CDuiString& CDuiString::operator+=(const TCHAR ch)
    {      
        TCHAR str[] = { ch, '\0' };
        Append(str);
        return *this;
    }

    bool CDuiString::operator == (LPCTSTR str) const { return (Compare(str) == 0); };
    bool CDuiString::operator != (LPCTSTR str) const { return (Compare(str) != 0); };
    bool CDuiString::operator <= (LPCTSTR str) const { return (Compare(str) <= 0); };
    bool CDuiString::operator <  (LPCTSTR str) const { return (Compare(str) <  0); };
    bool CDuiString::operator >= (LPCTSTR str) const { return (Compare(str) >= 0); };
    bool CDuiString::operator >  (LPCTSTR str) const { return (Compare(str) >  0); };

    void CDuiString::SetAt(int nIndex, TCHAR ch)
    {
        ASSERT(nIndex>=0 && nIndex<GetLength());
        m_pstr[nIndex] = ch;
    }

    int CDuiString::Compare(LPCTSTR lpsz) const 
    { 
        return _tcscmp(m_pstr, lpsz); 
    }

    int CDuiString::CompareNoCase(LPCTSTR lpsz) const 
    { 
        return _tcsicmp(m_pstr, lpsz); 
    }

    void CDuiString::MakeUpper() 
    { 
        _tcsupr(m_pstr); 
    }

    void CDuiString::MakeLower() 
    { 
        _tcslwr(m_pstr); 
    }

    CDuiString CDuiString::Left(int iLength) const
    {
        if( iLength < 0 ) iLength = 0;
        if( iLength > GetLength() ) iLength = GetLength();
        return CDuiString(m_pstr, iLength);
    }

    CDuiString CDuiString::Mid(int iPos, int iLength) const
    {
        if( iLength < 0 ) iLength = GetLength() - iPos;
        if( iPos + iLength > GetLength() ) iLength = GetLength() - iPos;
        if( iLength <= 0 ) return CDuiString();
        return CDuiString(m_pstr + iPos, iLength);
    }

    CDuiString CDuiString::Right(int iLength) const
    {
        int iPos = GetLength() - iLength;
        if( iPos < 0 ) {
            iPos = 0;
            iLength = GetLength();
        }
        return CDuiString(m_pstr + iPos, iLength);
    }

    int CDuiString::Find(TCHAR ch, int iPos /*= 0*/) const
    {
        ASSERT(iPos>=0 && iPos<=GetLength());
        if( iPos != 0 && (iPos < 0 || iPos >= GetLength()) ) return -1;
        LPCTSTR p = _tcschr(m_pstr + iPos, ch);
        if( p == NULL ) return -1;
        return (int)(p - m_pstr);
    }

    int CDuiString::Find(LPCTSTR pstrSub, int iPos /*= 0*/) const
    {
        ASSERT(!::IsBadStringPtr(pstrSub,-1));
        ASSERT(iPos>=0 && iPos<=GetLength());
        if( iPos != 0 && (iPos < 0 || iPos > GetLength()) ) return -1;
        LPCTSTR p = _tcsstr(m_pstr + iPos, pstrSub);
        if( p == NULL ) return -1;
        return (int)(p - m_pstr);
    }

    int CDuiString::ReverseFind(TCHAR ch) const
    {
        LPCTSTR p = _tcsrchr(m_pstr, ch);
        if( p == NULL ) return -1;
        return (int)(p - m_pstr);
    }

    int CDuiString::Replace(LPCTSTR pstrFrom, LPCTSTR pstrTo)
    {
        CDuiString sTemp;
        int nCount = 0;
        int iPos = Find(pstrFrom);
        if( iPos < 0 ) return 0;
        int cchFrom = (int) _tcslen(pstrFrom);
        int cchTo = (int) _tcslen(pstrTo);
        while( iPos >= 0 ) {
            sTemp = Left(iPos);
            sTemp += pstrTo;
            sTemp += Mid(iPos + cchFrom);
            Assign(sTemp);
            iPos = Find(pstrFrom, iPos + cchTo);
            nCount++;
        }
        return nCount;
    }

    int CDuiString::Format(LPCTSTR pstrFormat, ...)
    {
        int nRet;
        va_list Args;

        va_start(Args, pstrFormat);
        nRet = InnerFormat(pstrFormat, Args);
        va_end(Args);

        return nRet;

    }

    int CDuiString::SmallFormat(LPCTSTR pstrFormat, ...)
    {
        CDuiString sFormat = pstrFormat;
        TCHAR szBuffer[64] = { 0 };
        va_list argList;
        va_start(argList, pstrFormat);
        int iRet = ::_vsntprintf(szBuffer, sizeof(szBuffer), sFormat, argList);
        va_end(argList);
        Assign(szBuffer);
        return iRet;
    }

    int CDuiString::InnerFormat(LPCTSTR pstrFormat, va_list Args)
    {
#if _MSC_VER <= 1400
        TCHAR *szBuffer = NULL;
        int size = 512, nLen, counts;
        szBuffer = (TCHAR*)malloc(size);
        ZeroMemory(szBuffer, size);
        while (TRUE){
            counts = size / sizeof(TCHAR);
            nLen = _vsntprintf (szBuffer, counts, pstrFormat, Args);
            if (nLen != -1 && nLen < counts){
                break;
            }
            if (nLen == -1){
                size *= 2;
            }else{
                size += 1 * sizeof(TCHAR);
            }

            if ((szBuffer = (TCHAR*)realloc(szBuffer, size)) != NULL){
                ZeroMemory(szBuffer, size);
            }else{
                break;
            }
        }

        Assign(szBuffer);
        free(szBuffer);
        return nLen;
#else
        int nLen, totalLen;
        TCHAR *szBuffer;
        nLen = _vsntprintf(NULL, 0, pstrFormat, Args);
        totalLen = (nLen + 1)*sizeof(TCHAR);
        szBuffer = (TCHAR*)malloc(totalLen);
        ZeroMemory(szBuffer, totalLen);
        nLen = _vsntprintf(szBuffer, nLen + 1, pstrFormat, Args);
        Assign(szBuffer);
        free(szBuffer);
        return nLen;

#endif
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    //

    static UINT HashKey(LPCTSTR Key)
    {
        UINT i = 0;
        SIZE_T len = _tcslen(Key);
        while( len-- > 0 ) i = (i << 5) + i + Key[len];
        return i;
    }

    static UINT HashKey(const CDuiString& Key)
    {
        return HashKey((LPCTSTR)Key);
    };

    CStdStringPtrMap::CStdStringPtrMap(int nSize) : m_nCount(0)
    {
        if( nSize < 16 ) nSize = 16;
        m_nBuckets = nSize;
        m_aT = new TITEM*[nSize];
        memset(m_aT, 0, nSize * sizeof(TITEM*));
    }

    CStdStringPtrMap::~CStdStringPtrMap()
    {
        if( m_aT ) {
            int len = m_nBuckets;
            while( len-- ) {
                TITEM* pItem = m_aT[len];
                while( pItem ) {
                    TITEM* pKill = pItem;
                    pItem = pItem->pNext;
                    delete pKill;
                }
            }
            delete [] m_aT;
            m_aT = NULL;
        }
    }

    void CStdStringPtrMap::RemoveAll()
    {
        this->Resize(m_nBuckets);
    }

    void CStdStringPtrMap::Resize(int nSize)
    {
        if( m_aT ) {
            int len = m_nBuckets;
            while( len-- ) {
                TITEM* pItem = m_aT[len];
                while( pItem ) {
                    TITEM* pKill = pItem;
                    pItem = pItem->pNext;
                    delete pKill;
                }
            }
            delete [] m_aT;
            m_aT = NULL;
        }

        if( nSize < 0 ) nSize = 0;
        if( nSize > 0 ) {
            m_aT = new TITEM*[nSize];
            memset(m_aT, 0, nSize * sizeof(TITEM*));
        } 
        m_nBuckets = nSize;
        m_nCount = 0;
    }

    LPVOID CStdStringPtrMap::Find(LPCTSTR key, bool optimize) const
    {
        if( m_nBuckets == 0 || GetSize() == 0 ) return NULL;

        UINT slot = HashKey(key) % m_nBuckets;
        for( TITEM* pItem = m_aT[slot]; pItem; pItem = pItem->pNext ) {
            if( pItem->Key == key ) {
                if (optimize && pItem != m_aT[slot]) {
                    if (pItem->pNext) {
                        pItem->pNext->pPrev = pItem->pPrev;
                    }
                    pItem->pPrev->pNext = pItem->pNext;
                    pItem->pPrev = NULL;
                    pItem->pNext = m_aT[slot];
                    pItem->pNext->pPrev = pItem;
                    //将item移动至链条头部
                    m_aT[slot] = pItem;
                }
                return pItem->Data;
            }        
        }

        return NULL;
    }

    bool CStdStringPtrMap::Insert(LPCTSTR key, LPVOID pData)
    {
        if( m_nBuckets == 0 ) return false;
        if( Find(key) ) return false;

        // Add first in bucket
        UINT slot = HashKey(key) % m_nBuckets;
        TITEM* pItem = new TITEM;
        pItem->Key = key;
        pItem->Data = pData;
        pItem->pPrev = NULL;
        pItem->pNext = m_aT[slot];
        if (pItem->pNext)
            pItem->pNext->pPrev = pItem;
        m_aT[slot] = pItem;
        m_nCount++;
        return true;
    }

    LPVOID CStdStringPtrMap::Set(LPCTSTR key, LPVOID pData)
    {
        if( m_nBuckets == 0 ) return pData;

        if (GetSize()>0) {
            UINT slot = HashKey(key) % m_nBuckets;
            // Modify existing item
            for( TITEM* pItem = m_aT[slot]; pItem; pItem = pItem->pNext ) {
                if( pItem->Key == key ) {
                    LPVOID pOldData = pItem->Data;
                    pItem->Data = pData;
                    return pOldData;
                }
            }
        }

        Insert(key, pData);
        return NULL;
    }

    bool CStdStringPtrMap::Remove(LPCTSTR key)
    {
        if( m_nBuckets == 0 || GetSize() == 0 ) return false;

        UINT slot = HashKey(key) % m_nBuckets;
        TITEM** ppItem = &m_aT[slot];
        while( *ppItem ) {
            if( (*ppItem)->Key == key ) {
                TITEM* pKill = *ppItem;
                *ppItem = (*ppItem)->pNext;
                if (*ppItem)
                    (*ppItem)->pPrev = pKill->pPrev;
                delete pKill;
                m_nCount--;
                return true;
            }
            ppItem = &((*ppItem)->pNext);
        }

        return false;
    }

    int CStdStringPtrMap::GetSize() const
    {
#if 0//def _DEBUG
        int nCount = 0;
        int len = m_nBuckets;
        while( len-- ) {
            for( const TITEM* pItem = m_aT[len]; pItem; pItem = pItem->pNext ) nCount++;
        }
        ASSERT(m_nCount==nCount);
#endif
        return m_nCount;
    }

    LPCTSTR CStdStringPtrMap::GetAt(int iIndex) const
    {
        if( m_nBuckets == 0 || GetSize() == 0 ) return false;

        int pos = 0;
        int len = m_nBuckets;
        while( len-- ) {
            for( TITEM* pItem = m_aT[len]; pItem; pItem = pItem->pNext ) {
                if( pos++ == iIndex ) {
                    return pItem->Key.GetData();
                }
            }
        }

        return NULL;
    }

    LPCTSTR CStdStringPtrMap::operator[] (int nIndex) const
    {
        return GetAt(nIndex);
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CWaitCursor::CWaitCursor()
    {
        m_hOrigCursor = ::SetCursor(::LoadCursor(NULL, IDC_WAIT));
    }

    CWaitCursor::~CWaitCursor()
    {
        ::SetCursor(m_hOrigCursor);
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    //CImageString::CImageString()
    //{
    //    Clear();
    //}

    //CImageString::CImageString(const CImageString& image)
    //{
    //    Clone(image);
    //}

    //const CImageString& CImageString::operator=(const CImageString& image)
    //{
    //    Clone(image);
    //    return *this;
    //}

    //void CImageString::Clone(const CImageString& image)
    //{
    //    m_sImageAttribute = image.m_sImageAttribute;

    //    m_sImage = image.m_sImage;
    //    m_sResType = image.m_sResType;
    //    m_imageInfo = image.m_imageInfo;
    //    m_bLoadSuccess = image.m_bLoadSuccess;

    //    m_rcDest = image.m_rcDest;
    //    m_rcSource = image.m_rcSource;
    //    m_rcCorner = image.m_rcCorner;
    //    m_bFade = image.m_bFade;
    //    m_dwMask = image.m_dwMask;
    //    m_bHole = image.m_bHole;
    //    m_bTiledX = image.m_bTiledX;
    //    m_bTiledY = image.m_bTiledY;
    //}

    //CImageString::~CImageString()
    //{

    //}

    //const CDuiString& CImageString::GetAttributeString() const
    //{
    //    return m_sImageAttribute;
    //}

    //void CImageString::SetAttributeString(LPCTSTR pStrImageAttri)
    //{
    //    if (m_sImageAttribute == pStrImageAttri) return;
    //    Clear();
    //    m_sImageAttribute = pStrImageAttri;
    //    m_sImage = m_sImageAttribute;
    //}

    //bool CImageString::LoadImage(CPaintManagerUI* pManager)
    //{
    //    m_imageInfo = NULL;
    //    m_bLoadSuccess = true;
    //    ZeroMemory(&m_rcDest, sizeof(RECT));
    //    ZeroMemory(&m_rcSource, sizeof(RECT));
    //    ZeroMemory(&m_rcCorner, sizeof(RECT));
    //    m_bFade = 0xFF;
    //    m_dwMask = 0;
    //    m_bHole = false;
    //    m_bTiledX = false;
    //    m_bTiledY = false;
    //    ParseAttribute(m_sImageAttribute,*pManager->GetDPIObj());
    //    if (!m_bLoadSuccess) return false;

    //    const TImageInfo* data = NULL;
    //    if (m_sResType.IsEmpty())
    //    {
    //        data = pManager->GetImageEx((LPCTSTR)m_sImage, NULL, m_dwMask);
    //    }
    //    else
    //    {
    //        data = pManager->GetImageEx((LPCTSTR)m_sImage, (LPCTSTR)m_sResType, m_dwMask);
    //    }
    //    if (data == NULL)
    //    {
    //        m_bLoadSuccess = false;
    //        return false;
    //    }
    //    else
    //    {
    //        m_bLoadSuccess = true;
    //    }

    //    if (m_rcSource.left == 0 && m_rcSource.right == 0 && m_rcSource.top == 0 && m_rcSource.bottom == 0)
    //    {
    //        m_rcSource.right = data->nX;
    //        m_rcSource.bottom = data->nY;
    //    }
    //    if (m_rcSource.right > data->nX) m_rcSource.right = data->nX;
    //    if (m_rcSource.bottom > data->nY) m_rcSource.bottom = data->nY;
    //    m_imageInfo = const_cast<TImageInfo*>(data);

    //    return true;
    //}

    //bool CImageString::IsLoadSuccess()
    //{
    //    return !m_sImageAttribute.IsEmpty() && m_bLoadSuccess;
    //}

    //void CImageString::ModifyAttribute(LPCTSTR pStrModify)
    //{
    //    //ParseAttribute(pStrModify);
    //}

    //void CImageString::Clear()
    //{
    //    m_sImageAttribute.Empty();
    //    m_sImage.Empty();
    //    m_sResType.Empty();
    //    m_imageInfo = NULL;
    //    m_bLoadSuccess = true;
    //    ZeroMemory(&m_rcDest, sizeof(RECT));
    //    ZeroMemory(&m_rcSource, sizeof(RECT));
    //    ZeroMemory(&m_rcCorner, sizeof(RECT));
    //    m_bFade = 0xFF;
    //    m_dwMask = 0;
    //    m_bHole = false;
    //    m_bTiledX = false;
    //    m_bTiledY = false;
    //}

    //void CImageString::ParseAttribute(LPCTSTR pStrImage)
    //{
    //    if (pStrImage == NULL)
    //        return;

    //    // 1、aaa.jpg
    //    // 2、file='aaa.jpg' res='' restype='0' dest='0,0,0,0' source='0,0,0,0' corner='0,0,0,0' 
    //    // mask='#FF0000' fade='255' hole='false' xtiled='false' ytiled='false'
    //    CDuiString sItem;
    //    CDuiString sValue;
    //    LPTSTR pstr = NULL;

    //    while (*pStrImage != _T('\0'))
    //    {
    //        sItem.Empty();
    //        sValue.Empty();
    //        while (*pStrImage > _T('\0') && *pStrImage <= _T(' ')) pStrImage = ::CharNext(pStrImage);
    //        while (*pStrImage != _T('\0') && *pStrImage != _T('=') && *pStrImage > _T(' '))
    //        {
    //            LPTSTR pstrTemp = ::CharNext(pStrImage);
    //            while (pStrImage < pstrTemp)
    //            {
    //                sItem += *pStrImage++;
    //            }
    //        }
    //        while (*pStrImage > _T('\0') && *pStrImage <= _T(' ')) pStrImage = ::CharNext(pStrImage);
    //        if (*pStrImage++ != _T('=')) break;
    //        while (*pStrImage > _T('\0') && *pStrImage <= _T(' ')) pStrImage = ::CharNext(pStrImage);
    //        if (*pStrImage++ != _T('\'')) break;
    //        while (*pStrImage != _T('\0') && *pStrImage != _T('\''))
    //        {
    //            LPTSTR pstrTemp = ::CharNext(pStrImage);
    //            while (pStrImage < pstrTemp)
    //            {
    //                sValue += *pStrImage++;
    //            }
    //        }
    //        if (*pStrImage++ != _T('\'')) break;
    //        if (!sValue.IsEmpty())
    //        {
    //            if (sItem == _T("file") || sItem == _T("res"))
    //            {
    //                m_sImage = sValue;
    //                //if (g_Dpi.GetScale() != 100) {
    //                //    std::wstringstream wss;
    //                //    wss << L"@" << g_Dpi.GetScale() << L".";
    //                //    std::wstring suffix = wss.str();
    //                //    m_sImage.Replace(L".", suffix.c_str());
    //                //}
    //            }
    //            else if (sItem == _T("restype"))
    //            {                    
    //                m_sResType = sValue;
    //            }
    //            else if (sItem == _T("dest"))
    //            {
    //                m_rcDest.left = _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);
    //                m_rcDest.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
    //                m_rcDest.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
    //                m_rcDest.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);

    //                //g_Dpi.ScaleRect(&m_rcDest);
    //            }
    //            else if (sItem == _T("source"))
    //            {
    //                m_rcSource.left = _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);
    //                m_rcSource.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
    //                m_rcSource.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
    //                m_rcSource.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
    //                //g_Dpi.ScaleRect(&m_rcSource);
    //            }
    //            else if (sItem == _T("corner"))
    //            {
    //                m_rcCorner.left = _tcstol(sValue.GetData(), &pstr, 10);  ASSERT(pstr);
    //                m_rcCorner.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
    //                m_rcCorner.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
    //                m_rcCorner.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
    //                //g_Dpi.ScaleRect(&m_rcCorner);
    //            }
    //            else if (sItem == _T("mask"))
    //            {
    //                if (sValue[0] == _T('#')) m_dwMask = _tcstoul(sValue.GetData() + 1, &pstr, 16);
    //                else m_dwMask = _tcstoul(sValue.GetData(), &pstr, 16);
    //            }
    //            else if (sItem == _T("fade"))
    //            {
    //                m_bFade = (BYTE)_tcstoul(sValue.GetData(), &pstr, 10);
    //            }
    //            else if (sItem == _T("hole"))
    //            {
    //                m_bHole = (_tcscmp(sValue.GetData(), _T("true")) == 0);
    //            }
    //            else if (sItem == _T("xtiled"))
    //            {
    //                m_bTiledX = (_tcscmp(sValue.GetData(), _T("true")) == 0);
    //            }
    //            else if (sItem == _T("ytiled"))
    //            {
    //                m_bTiledY = (_tcscmp(sValue.GetData(), _T("true")) == 0);
    //            }
    //        }
    //        if (*pStrImage++ != _T(' ')) break;
    //    }
    //}

    //void CImageString::SetDest(const RECT &rcDest)
    //{
    //    m_rcDest = rcDest;
    //}

    //RECT CImageString::GetDest() const
    //{
    //    return m_rcDest;
    //}

    //const TImageInfo* CImageString::GetImageInfo() const
    //{
    //    return m_imageInfo;
    //}
} // namespace DuiLib