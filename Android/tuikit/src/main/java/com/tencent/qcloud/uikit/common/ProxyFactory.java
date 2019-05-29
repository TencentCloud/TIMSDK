package com.tencent.qcloud.uikit.common;

import android.support.v7.widget.RecyclerView;

import com.tencent.qcloud.uikit.api.contact.IContactDataProvider;
import com.tencent.qcloud.uikit.common.widget.InfoCacheView;
import com.tencent.qcloud.uikit.common.widget.UIKitTextView;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;


public class ProxyFactory {

    public static IContactDataProvider createContactProviderProxy(IContactDataProvider provider, RecyclerView.Adapter adapter) {
        ProxySubject proxy = new ProxySubject(provider, adapter);
        IContactDataProvider sub = (IContactDataProvider) Proxy.newProxyInstance(provider.getClass().getClassLoader(),
                provider.getClass().getInterfaces(), proxy);
        return sub;
    }


    public static class ProxySubject implements InvocationHandler {
        protected Object subject;
        private RecyclerView.Adapter adapter;

        public ProxySubject(Object subject, RecyclerView.Adapter adapter) {
            this.subject = subject;
            this.adapter = adapter;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            Object res = method.invoke(subject, args);
            if (method.getName().equals("addContact") || method.getName().equals("deleteContact")) {
                adapter.notifyDataSetChanged();
            }
            return res;
        }
    }


    public static InfoCacheView createInfoCacheViewProxy(InfoCacheView infoCacheView) {
        ProxyInfoCacheView proxy = new ProxyInfoCacheView(infoCacheView);
        InfoCacheView sub = (InfoCacheView) Proxy.newProxyInstance(infoCacheView.getClass().getClassLoader(),
                infoCacheView.getClass().getInterfaces(), proxy);
        return sub;
    }


    public static class ProxyInfoCacheView implements InvocationHandler {
        protected InfoCacheView subject;


        public ProxyInfoCacheView(InfoCacheView cacheView) {
            this.subject = cacheView;

        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            String methodName = method.getName();

            if (methodName.startsWith("set")) {
                if (subject.getRealView() != null) {
                    method.invoke(subject, args);
                } else {
                    subject.saveInfo(method, args);
                }
            }
            return null;
        }
    }
}
