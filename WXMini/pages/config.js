const CONFIG = {
    app: {
        sdkappid : '1400169722', // 填入创建腾讯云通讯应用获取到的 sdkappid
        accountType : '38142' // 填入在帐号体系集成配置中获取到的 accountType
    },
    users:[ // 将下面内容替换成通过控制台开发辅助工具生成的几组 identifier 和 userSig
        {
            identifier: 'webim2019',
            userSig: 'eJxlj81Og0AURvc8BZm1kZmBCYxJF1CaRgoNplXDiiAz6LX8d2glje*uYhNJvNtzcr*ci6brOtqHu9ssz5uVqkaW4n0Ox1hdPMH2xZEmqnU7MU-KD9a6GWaFUr2EySMMYrx3AEhawUFXI2zfIGKYsJnylEc0mnn94eFMbG5RelcgdcJRquH5b0X*8R0fHNrdd0*Djdes*rGPD9BZGyGICmN0U-qNV-m8dYFDwxXhbx8wrviYBK3fM*EOCcQkAizkvLHt4CtK06fYXAXi9mkgkpeoyzbdjB15lkn2R*hqSfhO4cRauKfQ9qn9gW-21yP'
            
        },
        {
            identifier: 'webim20191',
            userSig: 'eJxlj0FPg0AYRO-8CrJXje4uUIq3io0SSwOUmrQXsrAL-YrAShdpa-zvKjaRxLm*l5nMh6brOooXqxuWZU1Xq0SdpED6nY4wuv6DUgJPmEqMlv*D4iihFQnLlWgHSCzLohiPHeCiVpDDxehFChXFxCEj58DLZBj6LTExJrZjUjpWoBigP9*4XuhGwSPzXx9UUQTyVtbrTcaunFguF2X*g4mXcijp7RnxX0QeruZt345PVfbXTlThDv7lZzYITXP2zjtcmPee4UP4DZRtSz3o0kFlbi8Mm17ii1jOqLvoj1AUw-C9x*LUAP-BGmf2hc6sl92'
        }
    ],
    avChatRoomId: '20190201', // 群ID, 必选,这里为了快速演示，固定了群ID，可以由您指定。
}

module.exports = CONFIG;