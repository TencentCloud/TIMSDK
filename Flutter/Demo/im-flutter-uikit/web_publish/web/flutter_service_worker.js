'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "tim-js-friendship.js": "2e1a98b0bbc8c10961d44978637f4bdf",
"version.json": "82a10f7fcfa2dc4e098b5512acd1706a",
"splash/img/light-background.png": "94be6125b482716dccb6f49837f1a7df",
"splash/splash.js": "c6a271349a0cd249bdb6d3c4d12f5dcf",
"splash/style.css": "8327a119a599f3bd070470049ad2e7e5",
"favicon.ico": "6dc7d18e9ddae4c26dbffb428ecf2351",
"index.html": "bb0ff9258a09cf5189748b0a1edf0142",
"/": "bb0ff9258a09cf5189748b0a1edf0142",
"tim-js.js": "5e9078f0431d0b6ad82e3d5f862712b7",
"main.dart.js": "2a1af9cee853a5d9a4f017c2efdbe524",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"publish": "d41d8cd98f00b204e9800998ecf8427e",
"trtc-wrapper.js": "a943aca51f4bd5462589a67ed6ff8b83",
"trtc.js": "1190fdac50ca3d41e475383cb9dd33e0",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "0f95dab9ca31dc729a9beb628ff26984",
"tim-upload-plugin.js": "178b6b456a1c3e53b296018beef5c01b",
"assets/AssetManifest.json": "c08f442519713488d85937441c0f57dd",
"assets/NOTICES": "c08031813f0060f9bd63a88df77a8ead",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flutter_plugin_record_plus/images/microphone.png": "6c79804173fb6b4f683d876367b58209",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_1.png": "815bed94eab6306a3fd5d76c716dcc87",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_3.png": "3c71b25382c5f3dfa60c60aaa12c2c09",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_total.png": "a18b358d0c77c64ee5ece455cececd41",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_2.png": "d77042caf392a1f11a79c77c101c627d",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_6.png": "3d795e2110f3600b50d79e0390ca7f87",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_7.png": "efea8c723a364cff49734a4ffd8717aa",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_5.png": "3c374d2452775ebc234a2956be6cda47",
"assets/packages/flutter_plugin_record_plus/images/voice_volume_4.png": "02509496cce275847949fbd2ce5afc6d",
"assets/packages/tim_ui_kit/images/video_call.png": "5fb4729032e88fe51cf8861cd3ac7b05",
"assets/packages/tim_ui_kit/images/delete_emoji.png": "49999bb27f76a52a7cc5622882cbeaa6",
"assets/packages/tim_ui_kit/images/hangup.png": "234a8f657e5d8ee7f1119efcc3479b19",
"assets/packages/tim_ui_kit/images/face.svg": "b034d093b95eea710acb36f9eb7227d9",
"assets/packages/tim_ui_kit/images/default_group_head.png": "63df92e16288e84bb98f3183c95e79d0",
"assets/packages/tim_ui_kit/images/mic_on.png": "1e2dbbe85781159fdc983de798fb647e",
"assets/packages/tim_ui_kit/images/play_voice_send.gif": "1164831f79c6301032f09513536dd06f",
"assets/packages/tim_ui_kit/images/download.png": "3f72877c27d22a1b03a63bed037858c0",
"assets/packages/tim_ui_kit/images/custom-msg.svg": "263d7cb822abdae6e384e1206bde3632",
"assets/packages/tim_ui_kit/images/copy_message.png": "664532dbfccbac682fa0f31c47eb71bc",
"assets/packages/tim_ui_kit/images/file.svg": "6d3299417f8eade30883b6f4b6794546",
"assets/packages/tim_ui_kit/images/zip.png": "fbbd00fc6fefe17631406db86418145a",
"assets/packages/tim_ui_kit/images/voice_send.png": "d8d5978bccf7d487521341bd62971e59",
"assets/packages/tim_ui_kit/images/keyboard.svg": "66b23246440926d0bf3b4694bff257a0",
"assets/packages/tim_ui_kit/images/poke.svg": "e431353b0f3007f1ee7f875742d006f3",
"assets/packages/tim_ui_kit/images/clear.png": "dccc199575330a39ea957cdab9225d4b",
"assets/packages/tim_ui_kit/images/chat_permission_icon_camera.png": "a00aad49c635cc4d032bb2d459c11c6d",
"assets/packages/tim_ui_kit/images/arrow_back.png": "f424c487df5c2a38886a09e81ec9cbff",
"assets/packages/tim_ui_kit/images/unknown.png": "5e71d355dd39cf8de0dcc70458c6b5c2",
"assets/packages/tim_ui_kit/images/voice_call.png": "8f9d6b91741dfa56ddd120f1e330dbac",
"assets/packages/tim_ui_kit/images/message_sending.png": "f01aef547b39d14abe83c08a554fa77e",
"assets/packages/tim_ui_kit/images/video_call_self.png": "b59e594f992162af2068eda3d94c6905",
"assets/packages/tim_ui_kit/images/play_voice_receive.gif": "a3d199ed762dd7bac61a3d327cfdde26",
"assets/packages/tim_ui_kit/images/txt.png": "6e518e12822ab7c0dccc943025fb83d1",
"assets/packages/tim_ui_kit/images/card.svg": "24876bf7690808489ff050fc4a0d65e9",
"assets/packages/tim_ui_kit/images/add.svg": "2b9706fde82df012f9a0ccd90cac2bd5",
"assets/packages/tim_ui_kit/images/default_c2c_head.png": "2bbf1e1f58da86b632dc1ca780775946",
"assets/packages/tim_ui_kit/images/chat_permission_icon_mic.png": "9817cd04e039abca60002ea30b56bd1f",
"assets/packages/tim_ui_kit/images/voice-call.svg": "6c9267d1a7af7c94751c54d4a09387d0",
"assets/packages/tim_ui_kit/images/revoke_message.png": "d896daa71d3e6cad6572aab7f08bbecf",
"assets/packages/tim_ui_kit/images/excel.png": "16626eefe0c09df1174cb8c2937dcd79",
"assets/packages/tim_ui_kit/images/forward.png": "8c91b02cae5abc55dbbce8c0da8e5826",
"assets/packages/tim_ui_kit/images/image_icon.png": "479597d2b7fc098012aaaee4386c1ce4",
"assets/packages/tim_ui_kit/images/merge_forward.png": "8c32d616dae658cb8f5c449414b2d868",
"assets/packages/tim_ui_kit/images/voice_receive.png": "a8ca5107f1fd22945353f3244ed88240",
"assets/packages/tim_ui_kit/images/voice.svg": "8c55a5d2fbe618f47ef630acd0f389e6",
"assets/packages/tim_ui_kit/images/delete_message.png": "162ac17683f1b358ab0c85874a727ea9",
"assets/packages/tim_ui_kit/images/multi_message.png": "8e9d08a867576c704dd44f89aa7f4625",
"assets/packages/tim_ui_kit/images/forward_message.png": "afc880cff84782a799f964ff16d2c808",
"assets/packages/tim_ui_kit/images/logo_bottom.png": "fe6f2ed0c73f3610478361b545ea064d",
"assets/packages/tim_ui_kit/images/chat_permission_icon_file.png": "a8cf2f27969f8b3f9daf9b58ffcb27b1",
"assets/packages/tim_ui_kit/images/hands-free_off.png": "386173fa65aa5908f6f7d1d316e400be",
"assets/packages/tim_ui_kit/images/delete.png": "aec05999099c486a39eeb069323c759c",
"assets/packages/tim_ui_kit/images/hands-free_on.png": "2136140ba652a7bc05ce661341b1ff64",
"assets/packages/tim_ui_kit/images/pdf.png": "1f2b2034154798a0b98ea803ed9f0d3e",
"assets/packages/tim_ui_kit/images/ppt.png": "d0c0735d537acf24ba9f357057f9c50e",
"assets/packages/tim_ui_kit/images/mic_off.png": "a6f40eabe0c78a3c8082e455413122d1",
"assets/packages/tim_ui_kit/images/more.png": "1ef6c7afc9f4fad80b904f563b99816d",
"assets/packages/tim_ui_kit/images/screen.svg": "768077f5fd1a5a22f104fd7b4c730ebe",
"assets/packages/tim_ui_kit/images/play.png": "fad885c8d3c1d4db03c3990e3cca83d7",
"assets/packages/tim_ui_kit/images/word.png": "32c792cab3b4fc31f7228659678463da",
"assets/packages/tim_ui_kit/images/video-call.svg": "435de995fb99473d70529a3331c1ca36",
"assets/packages/tim_ui_kit/images/reply_message.png": "2048fd92f1550ff1b3948cfd0de52c8d",
"assets/packages/tim_ui_kit/images/photo.svg": "a183a8fe8e5c5d30dcf2e777c1e9e924",
"assets/packages/tim_ui_kit/images/close.png": "f4210c479ff421c8fd47ce9c1a9a170f",
"assets/packages/fluttertoast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/tim_ui_kit_sticker_plugin/images/delete_emoji.png": "49999bb27f76a52a7cc5622882cbeaa6",
"assets/packages/tim_ui_kit_calling_plugin/images/video_call.png": "5fb4729032e88fe51cf8861cd3ac7b05",
"assets/packages/tim_ui_kit_calling_plugin/images/calling.png": "4c5abc891b8e1147f94ba91520a60138",
"assets/packages/tim_ui_kit_calling_plugin/images/hangup.png": "234a8f657e5d8ee7f1119efcc3479b19",
"assets/packages/tim_ui_kit_calling_plugin/images/switch-camera.png": "cbf6dfa755fb4f73b0e80db3f6aeff34",
"assets/packages/tim_ui_kit_calling_plugin/images/trtccalling_ic_dialing_pressed.png": "2cc9354e572546840b2baf652fe7a6d3",
"assets/packages/tim_ui_kit_calling_plugin/images/meetingCall.png": "2782eb3eb9c3e068b64c3bfff6fc90ca",
"assets/packages/tim_ui_kit_calling_plugin/images/trtccalling_ic_handsfree_enable.png": "948cc79a3a472152c38e38f28cfeea5e",
"assets/packages/tim_ui_kit_calling_plugin/images/microphone-off.png": "aca33dd9cbfbadd582f5fe7662c25181",
"assets/packages/tim_ui_kit_calling_plugin/images/videoCall.png": "ec1b4798d21cd3ab74ccab752423beeb",
"assets/packages/tim_ui_kit_calling_plugin/images/camera-off.png": "c0381dc76132039d0ef6c0fc4cadfe15",
"assets/packages/tim_ui_kit_calling_plugin/images/trtccalling_ic_handsfree_disable.png": "748edfdf9d3c9473119a754822aec027",
"assets/packages/tim_ui_kit_calling_plugin/images/voice_call.png": "8f9d6b91741dfa56ddd120f1e330dbac",
"assets/packages/tim_ui_kit_calling_plugin/images/trtccalling_ic_dialing.png": "fc0d1469bfba9b3543e9436282efbdd7",
"assets/packages/tim_ui_kit_calling_plugin/images/video_call_self.png": "b59e594f992162af2068eda3d94c6905",
"assets/packages/tim_ui_kit_calling_plugin/images/search.png": "1aed9b4d038bf6890445861163bf8abb",
"assets/packages/tim_ui_kit_calling_plugin/images/audioCall.png": "06778faeaf47e380d37a756e0d50f680",
"assets/packages/tim_ui_kit_calling_plugin/images/minization-window.png": "08419136f5aa849b0ef856e8fa21c657",
"assets/packages/tim_ui_kit_calling_plugin/images/microphone-on.png": "fdee57311ddea5980e0d04aac25b4b1a",
"assets/packages/tim_ui_kit_calling_plugin/images/switchToAudio.png": "2ab965216915f35c37fc0fb6a6118341",
"assets/packages/tim_ui_kit_calling_plugin/images/camera-on.png": "3f7c4bf5a29fdfefa26f3860db87a6e1",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "62251cfa1d0249e09e03e4a9fe7734f6",
"assets/lib/country_list_pick-1.0.1+5/flags/tg.png": "1aac75adea3d024d892392e9fb521c83",
"assets/lib/country_list_pick-1.0.1+5/flags/me.png": "5f20ad5680a7bd5979d68363f7c989bb",
"assets/lib/country_list_pick-1.0.1+5/flags/la.png": "7bcfbc9eaf2567e0938499da1fa8ef0b",
"assets/lib/country_list_pick-1.0.1+5/flags/mr.png": "84a0f7bcdcacf970bfaa8fd7c2f4c1d2",
"assets/lib/country_list_pick-1.0.1+5/flags/ni.png": "e608db7e1cecd6afbd1420dd65def4b0",
"assets/lib/country_list_pick-1.0.1+5/flags/lv.png": "1c8de39890043c6b6c3ac9192965ecfc",
"assets/lib/country_list_pick-1.0.1+5/flags/om.png": "a73a7059c9c05355bdb07671556c2abe",
"assets/lib/country_list_pick-1.0.1+5/flags/af.png": "660f122fdb9e6eee8c23ce283e6c436e",
"assets/lib/country_list_pick-1.0.1+5/flags/cy.png": "dae1d011d2a55114add74dc0bde56400",
"assets/lib/country_list_pick-1.0.1+5/flags/bj.png": "ecb4f0778612d76a3b2d587a48e6ebd1",
"assets/lib/country_list_pick-1.0.1+5/flags/aq.png": "7f7fa7af21fc3dc4a3860fb1af8c4117",
"assets/lib/country_list_pick-1.0.1+5/flags/cn.png": "453d855f70ef7b89fac99895773f2535",
"assets/lib/country_list_pick-1.0.1+5/flags/gb-sct.png": "5dc90d9a83c3de79746d0bea814bf645",
"assets/lib/country_list_pick-1.0.1+5/flags/co.png": "61fa6d5907dedb1dbaa58b7517daad30",
"assets/lib/country_list_pick-1.0.1+5/flags/cx.png": "6d279739de88c345f3e31c124e018c84",
"assets/lib/country_list_pick-1.0.1+5/flags/ag.png": "a91460a442335d76faaaeb8d97fd27bf",
"assets/lib/country_list_pick-1.0.1+5/flags/ms.png": "607f3f0880bbf0a72585919d1c8852cf",
"assets/lib/country_list_pick-1.0.1+5/flags/md.png": "ab816594f9e3e91424526f8fbbed344b",
"assets/lib/country_list_pick-1.0.1+5/flags/zm.png": "8928cebab223c02f5bac81a969e898eb",
"assets/lib/country_list_pick-1.0.1+5/flags/vn.png": "0c15d40ac47d92791edac77ce8a9ef01",
"assets/lib/country_list_pick-1.0.1+5/flags/tf.png": "75f7175a0a8f2a93d966827f868e78d2",
"assets/lib/country_list_pick-1.0.1+5/flags/td.png": "af99aa9d657ede1ad49ecbb791f26c75",
"assets/lib/country_list_pick-1.0.1+5/flags/yt.png": "1f51e1cf368860492305e56573dc6013",
"assets/lib/country_list_pick-1.0.1+5/flags/lb.png": "c8b9c19874f273e635bc49de92831fb5",
"assets/lib/country_list_pick-1.0.1+5/flags/mf.png": "1f51e1cf368860492305e56573dc6013",
"assets/lib/country_list_pick-1.0.1+5/flags/lu.png": "e938221063036026b204215c622226c3",
"assets/lib/country_list_pick-1.0.1+5/flags/mq.png": "276e66e5e2a76f1e4fdeab5e523c5300",
"assets/lib/country_list_pick-1.0.1+5/flags/cz.png": "bec7038212c7d05c88b6b22f41ef2630",
"assets/lib/country_list_pick-1.0.1+5/flags/ae.png": "f0a95f247aa9ed04e8b8078fab47d116",
"assets/lib/country_list_pick-1.0.1+5/flags/cm.png": "f6e9475b28d20bcc3123dd5d0cca3279",
"assets/lib/country_list_pick-1.0.1+5/flags/bi.png": "542666e31144f9dcc5f33747354920f8",
"assets/lib/country_list_pick-1.0.1+5/flags/ar.png": "11c38bd60820e7c52352db376cdcfce9",
"assets/lib/country_list_pick-1.0.1+5/flags/as.png": "4fd332ffc9a2faf834357487f1d93e29",
"assets/lib/country_list_pick-1.0.1+5/flags/bh.png": "d0442fb0b456d43e267eedc5e5a1cd09",
"assets/lib/country_list_pick-1.0.1+5/flags/cl.png": "83b1b9005caef41c7fd2a6384e4927db",
"assets/lib/country_list_pick-1.0.1+5/flags/ad.png": "1aacf693aed2acfe02e61661bb1d15ca",
"assets/lib/country_list_pick-1.0.1+5/flags/mp.png": "614bfa3bf97f77850cb0233c08e53db2",
"assets/lib/country_list_pick-1.0.1+5/flags/lt.png": "adebbfcb4e666ae83c420572568491eb",
"assets/lib/country_list_pick-1.0.1+5/flags/mg.png": "36a09154b828ca93ef19cd370d3851ff",
"assets/lib/country_list_pick-1.0.1+5/flags/lc.png": "b780e4dfafbb6b834bc6e57248c0aacc",
"assets/lib/country_list_pick-1.0.1+5/flags/tr.png": "29bd4d66e8e156e4daea96ae1673c951",
"assets/lib/country_list_pick-1.0.1+5/flags/ua.png": "df5f575fc7266ae93ce527ad3703b7af",
"assets/lib/country_list_pick-1.0.1+5/flags/tv.png": "84a68e470361631eb793ace8cbfe88cd",
"assets/lib/country_list_pick-1.0.1+5/flags/vi.png": "8d9b59da5f89e37d023b1d98eaf3bd57",
"assets/lib/country_list_pick-1.0.1+5/flags/mt.png": "ee5f0e8bf7aa9c609c71b0539baf2fcb",
"assets/lib/country_list_pick-1.0.1+5/flags/no.png": "ef598a9fd443a87e16d0bfe79ee38cdf",
"assets/lib/country_list_pick-1.0.1+5/flags/mc.png": "8686af5cf0dba090f9e8b3bf3db68c6b",
"assets/lib/country_list_pick-1.0.1+5/flags/ch.png": "ad15a9e9baeabdbb949c694398368e4e",
"assets/lib/country_list_pick-1.0.1+5/flags/bl.png": "188d496b200dca60e47c87b852fc89b0",
"assets/lib/country_list_pick-1.0.1+5/flags/aw.png": "17d573958530d3787d85839f4e19ef56",
"assets/lib/country_list_pick-1.0.1+5/flags/bz.png": "a01fc77bbf3d59b7589879f8dd211912",
"assets/lib/country_list_pick-1.0.1+5/flags/bm.png": "7fcfe44364e7b13bc9bb6b1d38e67b44",
"assets/lib/country_list_pick-1.0.1+5/flags/ci.png": "f891481b6d8919fc50cc43e1dec24263",
"assets/lib/country_list_pick-1.0.1+5/flags/mu.png": "756616702622933b34b893646f7cd0eb",
"assets/lib/country_list_pick-1.0.1+5/flags/us.png": "d954766c5bb2a1c6b89f1371aba07b4c",
"assets/lib/country_list_pick-1.0.1+5/flags/tw.png": "445e9d2c92a405aaa57b4c62174d0a70",
"assets/lib/country_list_pick-1.0.1+5/flags/ye.png": "103e45a7c439a078ba088fadd20d9405",
"assets/lib/country_list_pick-1.0.1+5/flags/mw.png": "bede1e29f44deb775d43916acb5300b4",
"assets/lib/country_list_pick-1.0.1+5/flags/nl.png": "46b0d4835c3c23c0a8d4ef9f55db2b06",
"assets/lib/country_list_pick-1.0.1+5/flags/ls.png": "9e8c59af7733d1254452483c8ca4dfa3",
"assets/lib/country_list_pick-1.0.1+5/flags/bo.png": "1cf2bc64d508f720372a608f9e47b9bb",
"assets/lib/country_list_pick-1.0.1+5/flags/at.png": "608769b0492b16839f9f3e368ea32990",
"assets/lib/country_list_pick-1.0.1+5/flags/ck.png": "1b007eb85531f253b2ec15e958e3056f",
"assets/lib/country_list_pick-1.0.1+5/flags/by.png": "7eb8aca4382b94d17d531ecc675cc4ba",
"assets/lib/country_list_pick-1.0.1+5/flags/au.png": "3dbb2351f8350ef5624c6e1997d9b10e",
"assets/lib/country_list_pick-1.0.1+5/flags/bn.png": "3a12f43c65ad152d9fdeb237aa04af3a",
"assets/lib/country_list_pick-1.0.1+5/flags/ma.png": "7023a10ba108e7e3d1904214249025e4",
"assets/lib/country_list_pick-1.0.1+5/flags/nz.png": "8653747503cf69d01f4caca15955868a",
"assets/lib/country_list_pick-1.0.1+5/flags/lr.png": "744134e9ed215c287316f31c9ecb3fed",
"assets/lib/country_list_pick-1.0.1+5/flags/mv.png": "ff967b27286b888952220588dc0d33c3",
"assets/lib/country_list_pick-1.0.1+5/flags/tc.png": "3d9368fce5092fa8c7b7f01bee735532",
"assets/lib/country_list_pick-1.0.1+5/flags/ug.png": "a78b050a73b54f4fe97efda12e6db1f1",
"assets/lib/country_list_pick-1.0.1+5/flags/tt.png": "90abc818ecfb2f718a8c20fdb9c99de6",
"assets/lib/country_list_pick-1.0.1+5/flags/pl.png": "59b66c03277d662094a5deba6745e448",
"assets/lib/country_list_pick-1.0.1+5/flags/rs.png": "fe38b3c35c08ceb4ffe5372f51112bd0",
"assets/lib/country_list_pick-1.0.1+5/flags/in.png": "c40656915e40b8697d755adf12d67775",
"assets/lib/country_list_pick-1.0.1+5/flags/ge.png": "a3f4ed852dc2d31c6e00a26c4e43a9ab",
"assets/lib/country_list_pick-1.0.1+5/flags/gr.png": "b67f77b18d764959666ab02333f7f661",
"assets/lib/country_list_pick-1.0.1+5/flags/gs.png": "1556a6cb1f75a23f0593a58bc30989b5",
"assets/lib/country_list_pick-1.0.1+5/flags/gd.png": "ef641ce8a296a00174e6302b80f7b8bb",
"assets/lib/country_list_pick-1.0.1+5/flags/io.png": "696f3b4e093ed2f50057035e71d87652",
"assets/lib/country_list_pick-1.0.1+5/flags/hk.png": "e25e7660ae9e5739632077c31b891d69",
"assets/lib/country_list_pick-1.0.1+5/flags/kp.png": "6170ee90cf354cd114e7f4eb99896700",
"assets/lib/country_list_pick-1.0.1+5/flags/gb-nir.png": "4f3d96e67f55b5b8495ff9d104c6872d",
"assets/lib/country_list_pick-1.0.1+5/flags/kg.png": "52299a932b7d90ea7ae217ee20b90a53",
"assets/lib/country_list_pick-1.0.1+5/flags/pm.png": "1f51e1cf368860492305e56573dc6013",
"assets/lib/country_list_pick-1.0.1+5/flags/sv.png": "cffaa7e9fce1e1b9ff8e9e410d504ebe",
"assets/lib/country_list_pick-1.0.1+5/flags/re.png": "1f51e1cf368860492305e56573dc6013",
"assets/lib/country_list_pick-1.0.1+5/flags/sa.png": "4860952974607dd9df1e7abf159551d9",
"assets/lib/country_list_pick-1.0.1+5/flags/sc.png": "86322180a7157d640433b5541ef1cea2",
"assets/lib/country_list_pick-1.0.1+5/flags/st.png": "73e8c89284ebadf4b92ac3cd9d262c72",
"assets/lib/country_list_pick-1.0.1+5/flags/ke.png": "a8ab4857f02900810cfcf76a2f3b44e2",
"assets/lib/country_list_pick-1.0.1+5/flags/im.png": "b39b706ce090a11b45f199faee9a1536",
"assets/lib/country_list_pick-1.0.1+5/flags/kr.png": "1fb2e249ed60a470219a00366d7f147d",
"assets/lib/country_list_pick-1.0.1+5/flags/gf.png": "fba33680ae29a3a37d31133809441d62",
"assets/lib/country_list_pick-1.0.1+5/flags/dj.png": "12e894c0ced52efd15dfca315a16f33b",
"assets/lib/country_list_pick-1.0.1+5/flags/gq.png": "508308fd6a78dea099ec2f729985099a",
"assets/lib/country_list_pick-1.0.1+5/flags/gp.png": "1f51e1cf368860492305e56573dc6013",
"assets/lib/country_list_pick-1.0.1+5/flags/dk.png": "4809c56e7a1f204328e43339f6f84db5",
"assets/lib/country_list_pick-1.0.1+5/flags/gg.png": "486cde076860a1b735e44959cb22afa3",
"assets/lib/country_list_pick-1.0.1+5/flags/il.png": "75608d293f7e1b0b12b17d950b8f918b",
"assets/lib/country_list_pick-1.0.1+5/flags/pn.png": "1b483de59d98dbab49af3a2a818f567c",
"assets/lib/country_list_pick-1.0.1+5/flags/sb.png": "69cf6fb36fda272ff52a4c913f170871",
"assets/lib/country_list_pick-1.0.1+5/flags/py.png": "b1f3a3e40b9f3bff417d959b3a6e3b79",
"assets/lib/country_list_pick-1.0.1+5/flags/ru.png": "4fcf2660173f696388dea92667de164a",
"assets/lib/country_list_pick-1.0.1+5/flags/kw.png": "072729cd962f32af330d7b151b15a138",
"assets/lib/country_list_pick-1.0.1+5/flags/do.png": "0a1041d6a0498bc11b52fca93c083156",
"assets/lib/country_list_pick-1.0.1+5/flags/gt.png": "d1a8528dc7ad9490290b2e99a2f2d9af",
"assets/lib/country_list_pick-1.0.1+5/flags/gb.png": "4f3d96e67f55b5b8495ff9d104c6872d",
"assets/lib/country_list_pick-1.0.1+5/flags/gu.png": "0760912df59b966b2f5dcd1bacd2630b",
"assets/lib/country_list_pick-1.0.1+5/flags/je.png": "cccc2aa2d3d99a8dccb68785f99139eb",
"assets/lib/country_list_pick-1.0.1+5/flags/hm.png": "3dbb2351f8350ef5624c6e1997d9b10e",
"assets/lib/country_list_pick-1.0.1+5/flags/sg.png": "c922d92eccf8c8f495a1015179dcc026",
"assets/lib/country_list_pick-1.0.1+5/flags/pk.png": "1b66722e1c4f02f3377ec8f2a61c10bf",
"assets/lib/country_list_pick-1.0.1+5/flags/sr.png": "70e657e4b1dc16e0d0671b857d391e40",
"assets/lib/country_list_pick-1.0.1+5/flags/se.png": "d64ec3de57b785c23f588bd3083e538c",
"assets/lib/country_list_pick-1.0.1+5/flags/jp.png": "6f0b04f379cdc6cc8729e45a76f45290",
"assets/lib/country_list_pick-1.0.1+5/flags/gw.png": "57a0a4704b45fc701e5b8574241b474e",
"assets/lib/country_list_pick-1.0.1+5/flags/eh.png": "ba5d85e8e5e77a03c44f70a912191789",
"assets/lib/country_list_pick-1.0.1+5/flags/dz.png": "9d64cd78c49a15008cbe8652b231798d",
"assets/lib/country_list_pick-1.0.1+5/flags/ga.png": "488e48ef9feb3c76d911a043deee71b8",
"assets/lib/country_list_pick-1.0.1+5/flags/fr.png": "02aea38f9e516467efca62ca26b7046e",
"assets/lib/country_list_pick-1.0.1+5/flags/dm.png": "4773d4707ada9bb01e74f206fc17abbe",
"assets/lib/country_list_pick-1.0.1+5/flags/hn.png": "92fe9380f7dbf95783060b134511084b",
"assets/lib/country_list_pick-1.0.1+5/flags/sd.png": "c4ebfd8e408c64752171ed332ecaf84d",
"assets/lib/country_list_pick-1.0.1+5/flags/rw.png": "1ef7abcf069ef349ad94739a5632a38b",
"assets/lib/country_list_pick-1.0.1+5/flags/ph.png": "f7d9f8ca1f2f42be3fc16541d8f23f29",
"assets/lib/country_list_pick-1.0.1+5/flags/ss.png": "a35ee2f46bb2775ae97a6243bf488314",
"assets/lib/country_list_pick-1.0.1+5/flags/qa.png": "35de25a58f356e13ac87e140cfc80bb3",
"assets/lib/country_list_pick-1.0.1+5/flags/pe.png": "781b81b1ba1d5f9c6409abb4d3c84333",
"assets/lib/country_list_pick-1.0.1+5/flags/pr.png": "4c013d5006b46b1b1f3371ee10f896cd",
"assets/lib/country_list_pick-1.0.1+5/flags/si.png": "c428d79ab05873b881c7851210aa5f29",
"assets/lib/country_list_pick-1.0.1+5/flags/ht.png": "0dbee740251a8fb814a055fedf859188",
"assets/lib/country_list_pick-1.0.1+5/flags/es.png": "075c30fd313b802b80b34687e554cf4f",
"assets/lib/country_list_pick-1.0.1+5/flags/gl.png": "0bf006d770eb8525708867a301765a95",
"assets/lib/country_list_pick-1.0.1+5/flags/gm.png": "e5d632aed932e81f47eecc98de383ec0",
"assets/lib/country_list_pick-1.0.1+5/flags/er.png": "d830edf23589c5ddc068cc70a0e19249",
"assets/lib/country_list_pick-1.0.1+5/flags/fi.png": "13e2f1188d79003d314353820122fc17",
"assets/lib/country_list_pick-1.0.1+5/flags/ee.png": "1090c5cd1d6edac56ea172b63e298b15",
"assets/lib/country_list_pick-1.0.1+5/flags/kn.png": "7553a352430f9740a081151c3ab089eb",
"assets/lib/country_list_pick-1.0.1+5/flags/hu.png": "0b4115c034ece729b7119ab4e3f4bb39",
"assets/lib/country_list_pick-1.0.1+5/flags/iq.png": "9319b4faa07fa82efd33d33ea496e174",
"assets/lib/country_list_pick-1.0.1+5/flags/ky.png": "5e2507311516d33660dbba97c489813d",
"assets/lib/country_list_pick-1.0.1+5/flags/sh.png": "4f3d96e67f55b5b8495ff9d104c6872d",
"assets/lib/country_list_pick-1.0.1+5/flags/ps.png": "01f934c2da8a4d7f75392b6ff251d0f1",
"assets/lib/country_list_pick-1.0.1+5/flags/pf.png": "c24b43b17213fa4bf710cce0a5666cb9",
"assets/lib/country_list_pick-1.0.1+5/flags/sj.png": "ef598a9fd443a87e16d0bfe79ee38cdf",
"assets/lib/country_list_pick-1.0.1+5/flags/id.png": "155344cb61fa85ff8680fe44a0c40515",
"assets/lib/country_list_pick-1.0.1+5/flags/is.png": "67050355a791ebfdbd1ee963b5130073",
"assets/lib/country_list_pick-1.0.1+5/flags/eg.png": "163974b6e28267d22bb86eb53de4be63",
"assets/lib/country_list_pick-1.0.1+5/flags/fk.png": "e17b4125fce77340c33ea23960382280",
"assets/lib/country_list_pick-1.0.1+5/flags/fj.png": "038d2866c0d421dedc3ec8a3a08d81e7",
"assets/lib/country_list_pick-1.0.1+5/flags/gn.png": "ee4e661f9d5204573dd544c8843a0bb8",
"assets/lib/country_list_pick-1.0.1+5/flags/gy.png": "d9ac767c16b5d3a2ccd303b6bfc9a202",
"assets/lib/country_list_pick-1.0.1+5/flags/ir.png": "55b4c27ee8268c0e4d23a11028a02777",
"assets/lib/country_list_pick-1.0.1+5/flags/km.png": "5ac2d15931b9c633bb081adbceaee663",
"assets/lib/country_list_pick-1.0.1+5/flags/ie.png": "7ecceecab6cca823f88cef2cc6f6cece",
"assets/lib/country_list_pick-1.0.1+5/flags/kz.png": "fca455cb0b4a07700a536999108aa073",
"assets/lib/country_list_pick-1.0.1+5/flags/ro.png": "aeeaef3e507b62f710359e3976b574ce",
"assets/lib/country_list_pick-1.0.1+5/flags/sk.png": "87b04462076cf5a131437ffd5806772c",
"assets/lib/country_list_pick-1.0.1+5/flags/pg.png": "64e4dab43ebe44ec9c660f865b83cdd5",
"assets/lib/country_list_pick-1.0.1+5/flags/pt.png": "f9a2dd01d695901f6d5df9786fb94b28",
"assets/lib/country_list_pick-1.0.1+5/flags/so.png": "2fb38d1f81d22648e9fb09fe84889f17",
"assets/lib/country_list_pick-1.0.1+5/flags/sx.png": "bc6ff957c83ce667c8fd182d98a3a089",
"assets/lib/country_list_pick-1.0.1+5/flags/hr.png": "9a720e9dd52033270f9f1017cfba3bce",
"assets/lib/country_list_pick-1.0.1+5/flags/ki.png": "acc84e8f81d0d523ef834cb4b5e0780a",
"assets/lib/country_list_pick-1.0.1+5/flags/jm.png": "f52bd4a303b158adc13398edad699d8f",
"assets/lib/country_list_pick-1.0.1+5/flags/eu.png": "9071dd73d728d00cd9d28ddc41332275",
"assets/lib/country_list_pick-1.0.1+5/flags/ec.png": "3f59e5070153ea5efe7da4561d311aa8",
"assets/lib/country_list_pick-1.0.1+5/flags/et.png": "e914d5910342f9356198084b624c260d",
"assets/lib/country_list_pick-1.0.1+5/flags/fo.png": "a0ce3561039b6741bf8a4e38ec92f2a8",
"assets/lib/country_list_pick-1.0.1+5/flags/kh.png": "672d4f09957d1bf2fe8f425c3e330233",
"assets/lib/country_list_pick-1.0.1+5/flags/sy.png": "4bdfb178d0b5c37d1a49447644810642",
"assets/lib/country_list_pick-1.0.1+5/flags/sn.png": "b44808bac0e786e330e2d1ff70fc8661",
"assets/lib/country_list_pick-1.0.1+5/flags/pw.png": "3fe5f5ac165f4d7a11847fa58323ebe3",
"assets/lib/country_list_pick-1.0.1+5/flags/sl.png": "aa42873d1b3b7097d5bf5394fd7db249",
"assets/lib/country_list_pick-1.0.1+5/flags/gb-eng.png": "7ad705e446f51de6798a3cd931c678cf",
"assets/lib/country_list_pick-1.0.1+5/flags/fm.png": "3ca2968179d1119db38353ef014a6196",
"assets/lib/country_list_pick-1.0.1+5/flags/gi.png": "02ec1f60b6633c4aa5b5577a6e1208e7",
"assets/lib/country_list_pick-1.0.1+5/flags/de.png": "c0d0800fa9091a0e8830d78a29e4091a",
"assets/lib/country_list_pick-1.0.1+5/flags/gh.png": "0e83b81570c011ee260e9404309369bd",
"assets/lib/country_list_pick-1.0.1+5/flags/jo.png": "aad9bc74c2a920f7c84e5cfe3a762fde",
"assets/lib/country_list_pick-1.0.1+5/flags/it.png": "3e556834b2a2bd13043fc750f2134261",
"assets/lib/country_list_pick-1.0.1+5/flags/pa.png": "368848b034d627f51011bee7ff6f7fe1",
"assets/lib/country_list_pick-1.0.1+5/flags/sz.png": "06062677a5d2cbaab9a38e262ff41484",
"assets/lib/country_list_pick-1.0.1+5/flags/sm.png": "bb92ccdf55b3e911b4dbd1ad323025b8",
"assets/lib/country_list_pick-1.0.1+5/flags/tn.png": "76073847b409dccabe9c1eda3ac05f91",
"assets/lib/country_list_pick-1.0.1+5/flags/ml.png": "95ab1e6fbcf0b539ad91dac85dd78048",
"assets/lib/country_list_pick-1.0.1+5/flags/cg.png": "03fd398d46ee2e45771139ba34595da7",
"assets/lib/country_list_pick-1.0.1+5/flags/ax.png": "1db33dac4ca169fbb04ff422fe3b32fe",
"assets/lib/country_list_pick-1.0.1+5/flags/ao.png": "2a02b1dab7b7eef4600bde31e20d656d",
"assets/lib/country_list_pick-1.0.1+5/flags/bt.png": "79013c2037a8dbe805c608a6fca4b334",
"assets/lib/country_list_pick-1.0.1+5/flags/an.png": "f631f7f4261fef69ab47a15437b819e9",
"assets/lib/country_list_pick-1.0.1+5/flags/bb.png": "482aba486df393337e7ca37e1809b34a",
"assets/lib/country_list_pick-1.0.1+5/flags/cf.png": "45617cf482d8526b23147bc78d00f50d",
"assets/lib/country_list_pick-1.0.1+5/flags/mm.png": "b33e771bcb7cb6e8bc67814491b5077d",
"assets/lib/country_list_pick-1.0.1+5/flags/li.png": "3a5673239686961098d67637847e4c01",
"assets/lib/country_list_pick-1.0.1+5/flags/na.png": "90a4627e0c4b8624d2ca0422d44f0905",
"assets/lib/country_list_pick-1.0.1+5/flags/mz.png": "41bada1d37528a6aa55b407ae956a815",
"assets/lib/country_list_pick-1.0.1+5/flags/to.png": "5ff2d5324888c0836390dec09203b038",
"assets/lib/country_list_pick-1.0.1+5/flags/vg.png": "cec52738e3c09558332834ed435c9843",
"assets/lib/country_list_pick-1.0.1+5/flags/ve.png": "1143cb8025ec96e7caca26785962d518",
"assets/lib/country_list_pick-1.0.1+5/flags/tz.png": "c7beca272acad189bdc2aa6a1d6d52c8",
"assets/lib/country_list_pick-1.0.1+5/flags/tm.png": "587e852cf79984b2874546d9cbdf339d",
"assets/lib/country_list_pick-1.0.1+5/flags/mx.png": "ff34b81849b3cbfbc162ae60b79bcdfc",
"assets/lib/country_list_pick-1.0.1+5/flags/nc.png": "27fd7db92e8e95f7f40d551cbea09a85",
"assets/lib/country_list_pick-1.0.1+5/flags/mo.png": "3a6d8bece521864cb37d489c37f1633e",
"assets/lib/country_list_pick-1.0.1+5/flags/lk.png": "5ca339d7f63b878f1f8b82d43cf9aacf",
"assets/lib/country_list_pick-1.0.1+5/flags/cd.png": "e8f2cea779ce872d08201597b02c597f",
"assets/lib/country_list_pick-1.0.1+5/flags/al.png": "1bf7583a605aa5330ef94c112e5bf9df",
"assets/lib/country_list_pick-1.0.1+5/flags/bw.png": "d2e74d89d909ad4a25a9c5717de2f7dc",
"assets/lib/country_list_pick-1.0.1+5/flags/cr.png": "2048f5b6386d9e67512a6779d5d82128",
"assets/lib/country_list_pick-1.0.1+5/flags/bv.png": "ef598a9fd443a87e16d0bfe79ee38cdf",
"assets/lib/country_list_pick-1.0.1+5/flags/am.png": "ebf44c9104fdcdc5cafb4ce952a54d59",
"assets/lib/country_list_pick-1.0.1+5/flags/az.png": "3422a1d417a2a13abfffaa0ab851c48e",
"assets/lib/country_list_pick-1.0.1+5/flags/ba.png": "80ddc6e6f02020d84c657b5d86ff7684",
"assets/lib/country_list_pick-1.0.1+5/flags/mn.png": "7dc35bfb7e8e96d0fc3c30eb008a091a",
"assets/lib/country_list_pick-1.0.1+5/flags/nu.png": "444e791cfb272edeb705a95f83185191",
"assets/lib/country_list_pick-1.0.1+5/flags/my.png": "4790d277bd7b03b793c9c8a54d0db16c",
"assets/lib/country_list_pick-1.0.1+5/flags/tl.png": "03331ba7e3de6f6e56c7a8e427df9757",
"assets/lib/country_list_pick-1.0.1+5/flags/ws.png": "d3a893789296b0caddb296f6de923bf0",
"assets/lib/country_list_pick-1.0.1+5/flags/th.png": "26c730c4f3d8990011d72b62cefedff7",
"assets/lib/country_list_pick-1.0.1+5/flags/xk.png": "b945091e2392a5e0947fd034de30ffb6",
"assets/lib/country_list_pick-1.0.1+5/flags/nf.png": "591a33bd418e460020b80a1727917ab5",
"assets/lib/country_list_pick-1.0.1+5/flags/ly.png": "f19e77eaf524cb9af57108b60cd3b47d",
"assets/lib/country_list_pick-1.0.1+5/flags/ai.png": "9ad8f6fbd2dfffc221ddc86157be356f",
"assets/lib/country_list_pick-1.0.1+5/flags/br.png": "ae1749ed87f9a3afca2851247d4546cc",
"assets/lib/country_list_pick-1.0.1+5/flags/cv.png": "b25db20c51c841b496c8668bb5b4d1cf",
"assets/lib/country_list_pick-1.0.1+5/flags/be.png": "d7452c934da368ce542b49037a4226fb",
"assets/lib/country_list_pick-1.0.1+5/flags/ca.png": "65f9c9629bfe9e4923815813e5431efd",
"assets/lib/country_list_pick-1.0.1+5/flags/bd.png": "2f4a6ef7a097f677d795ccf42e2a2f11",
"assets/lib/country_list_pick-1.0.1+5/flags/cw.png": "c4c1ed5b99f70096e8338a8772069446",
"assets/lib/country_list_pick-1.0.1+5/flags/bs.png": "4dbfd7a2c196208ce15de6079cacc9cc",
"assets/lib/country_list_pick-1.0.1+5/flags/ng.png": "1beb46365517bf1d99b1d5b730db108b",
"assets/lib/country_list_pick-1.0.1+5/flags/mk.png": "72c60ba396e6ef68402fd4314fba82be",
"assets/lib/country_list_pick-1.0.1+5/flags/np.png": "6e91204f10b316cd7cd94a847f294fe9",
"assets/lib/country_list_pick-1.0.1+5/flags/va.png": "d4076a8fe13f708cb048cf59b2211672",
"assets/lib/country_list_pick-1.0.1+5/flags/uz.png": "09314fdd69b5f2f807f34849ab7e58fd",
"assets/lib/country_list_pick-1.0.1+5/flags/um.png": "d954766c5bb2a1c6b89f1371aba07b4c",
"assets/lib/country_list_pick-1.0.1+5/flags/tk.png": "c2b01fb241c3376142db12a5ca21d75f",
"assets/lib/country_list_pick-1.0.1+5/flags/vc.png": "b2cd5b4716ce8788fa15a4d26ae68e86",
"assets/lib/country_list_pick-1.0.1+5/flags/zw.png": "9a81708fa126804fdd75bdcac6cb390f",
"assets/lib/country_list_pick-1.0.1+5/flags/nr.png": "acdf572d1e7621435a326b42d7ad7eae",
"assets/lib/country_list_pick-1.0.1+5/flags/ne.png": "f283f366eae7933f199f21c386ab2bd5",
"assets/lib/country_list_pick-1.0.1+5/flags/cu.png": "ac8319acc61b156f7bdb253c3a04c616",
"assets/lib/country_list_pick-1.0.1+5/flags/bq.png": "46b0d4835c3c23c0a8d4ef9f55db2b06",
"assets/lib/country_list_pick-1.0.1+5/flags/bf.png": "6a7837fbb20d1d707edac18a772d0aca",
"assets/lib/country_list_pick-1.0.1+5/flags/bg.png": "a79a31dba572a83d51619b257523ea43",
"assets/lib/country_list_pick-1.0.1+5/flags/cc.png": "9d7c8bcf3cdc767a7f31426ee30dab60",
"assets/lib/country_list_pick-1.0.1+5/flags/gb-wls.png": "a52fc5da481dc1861efd0056b671bea2",
"assets/lib/country_list_pick-1.0.1+5/flags/mh.png": "5d44d2d6bc8ef667daaab82c431ca023",
"assets/lib/country_list_pick-1.0.1+5/flags/za.png": "6d7ebb91ce1fddfabf57176255d332af",
"assets/lib/country_list_pick-1.0.1+5/flags/uy.png": "afc590e6c5e6ec044e854a94aa5c641f",
"assets/lib/country_list_pick-1.0.1+5/flags/wf.png": "b7e46678b1f20fd6bc752a0fb34f492e",
"assets/lib/country_list_pick-1.0.1+5/flags/vu.png": "1f3f683c41e68e68ca1e8532826f2238",
"assets/lib/country_list_pick-1.0.1+5/flags/tj.png": "15af71069779d3b0509ffee9251f9588",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/assets/logo_transparent.png": "ad1eb7e11791871525c868c54722357c",
"assets/assets/default_avatar.png": "fa9cc660bcf46fa29957bd03471246ac",
"assets/assets/im_logo.png": "a6006c3f1b274e63647b1e1af7929107",
"assets/assets/im_banner.png": "983217815c16ff0638ce329623e29dc7",
"assets/assets/newContact_bright.png": "28fc3ad1a5971a99f1912b98453ec447",
"assets/assets/profile_active.png": "1ca9313390fe37538dafa0a7e3b0c163",
"assets/assets/groupList_fantasy.png": "e98981dcd6d7352691e1138c45484f3e",
"assets/assets/pin_red.png": "a9b3f176b86b5f7e5b76c33bef61fa95",
"assets/assets/newContact_solemn.png": "abc04942d8fb177d4f388af0f2c945f8",
"assets/assets/topic_icon.png": "164616a20e6f1043953547871e978fac",
"assets/assets/icon_wechat_moments.jpg": "5a346866df1d9a48bc7c228ccb1cdb80",
"assets/assets/launch_icon.png": "18d2b4db60b73f4ae7258fb90a214674",
"assets/assets/blackList.png": "d634d762929010557b93dc3bbad719da",
"assets/assets/custom_face_resource/4351/ys02@2x.png": "d0fcdbf427e442af607031be0da7dddd",
"assets/assets/custom_face_resource/4351/ys10@2x.png": "9db088e6918729908680f7ef0fca63a4",
"assets/assets/custom_face_resource/4351/ys12@2x.png": "53792f6d9ac954c50859dae954576ffa",
"assets/assets/custom_face_resource/4351/ys00@2x.png": "a9d5287897d593bde802ee96c2c7522f",
"assets/assets/custom_face_resource/4351/ys04@2x.png": "b40044d96ac4ac7806d4ae3fa6e7550c",
"assets/assets/custom_face_resource/4351/ys08@2x.png": "8ba9a9801bc5128dd2affeb82800e1de",
"assets/assets/custom_face_resource/4351/ys14@2x.png": "b5c5cfcbf7d9f8fe640085eb5d33dda3",
"assets/assets/custom_face_resource/4351/ys06@2x.png": "44fffdf7a4f42163a780780fe5a8a667",
"assets/assets/custom_face_resource/4351/ys03@2x.png": "18d2142c1237bdd2a6189d83b962fd7f",
"assets/assets/custom_face_resource/4351/ys11@2x.png": "9b752ab254c4091220116c77a931c307",
"assets/assets/custom_face_resource/4351/ys13@2x.png": "af5e5133259331025047338c1df305d9",
"assets/assets/custom_face_resource/4351/ys01@2x.png": "1fb7be3bfdff928d81730e1e030f8711",
"assets/assets/custom_face_resource/4351/ys05@2x.png": "453fa78ca2d4267495eec5d06cd3205b",
"assets/assets/custom_face_resource/4351/ys09@2x.png": "0230788af301e99de8fc0821ec45dd0c",
"assets/assets/custom_face_resource/4351/menu@2x.png": "a9d5287897d593bde802ee96c2c7522f",
"assets/assets/custom_face_resource/4351/ys15@2x.png": "c6ed953441649e617978c0954f503941",
"assets/assets/custom_face_resource/4351/ys07@2x.png": "48706f79e1fc5155e8488d5b4555ca3f",
"assets/assets/custom_face_resource/4350/yz01@2x.png": "0eeccf75ef05e3691a9471e7d3feec39",
"assets/assets/custom_face_resource/4350/yz13@2x.png": "95d857794573ec3a7d42c27c4b364d4d",
"assets/assets/custom_face_resource/4350/yz11@2x.png": "f569124c2a7fe0c5aff73acb50558226",
"assets/assets/custom_face_resource/4350/yz03@2x.png": "cdf3583dd507684e66cc5385c0a346c1",
"assets/assets/custom_face_resource/4350/yz07@2x.png": "24268381e6c718c3c5ab3a674308a3c6",
"assets/assets/custom_face_resource/4350/yz15@2x.png": "46ec5f97ee6302cfadcc1c67114d43a8",
"assets/assets/custom_face_resource/4350/yz17@2x.png": "2739c6820f6fd1704adc4e98e1fb4d8b",
"assets/assets/custom_face_resource/4350/yz09@2x.png": "db342a9011e1815dd9bc7de54473f5e6",
"assets/assets/custom_face_resource/4350/yz05@2x.png": "de87a11f6103576470da01ea40c5cdc8",
"assets/assets/custom_face_resource/4350/yz00@2x.png": "2b6c0bfaaaa6a8b176ccf1bb6251d5b5",
"assets/assets/custom_face_resource/4350/yz12@2x.png": "7a6d1fae173fea4f510ccc79fb810b24",
"assets/assets/custom_face_resource/4350/yz10@2x.png": "9513d94e7533551e6a136340e845dd7a",
"assets/assets/custom_face_resource/4350/yz02@2x.png": "e9300a2d54b674570d545b478a597bb9",
"assets/assets/custom_face_resource/4350/yz06@2x.png": "0ac5a54ce1528fb15a8eb12dd9fcbffb",
"assets/assets/custom_face_resource/4350/yz14@2x.png": "10b43ce46c8ca6fe5ee5e4c31a932bb1",
"assets/assets/custom_face_resource/4350/menu@2x.png": "2b6c0bfaaaa6a8b176ccf1bb6251d5b5",
"assets/assets/custom_face_resource/4350/yz08@2x.png": "adced74d2d4285cfa8d78862e1d9a605",
"assets/assets/custom_face_resource/4350/yz16@2x.png": "de9c169b055541f0a9b8100fa1cd93a1",
"assets/assets/custom_face_resource/4350/yz04@2x.png": "2fb76abc2bb9576accfbe7d9bc4fcb91",
"assets/assets/custom_face_resource/4352/gcs00@2x.png": "2c9b80ed5c6a76d503609cc21214754c",
"assets/assets/custom_face_resource/4352/gcs12@2x.png": "3768acab74871fa8e9c154843844c540",
"assets/assets/custom_face_resource/4352/gcs10@2x.png": "3892a7dc7d8d2d7786b079c8800d5614",
"assets/assets/custom_face_resource/4352/gcs02@2x.png": "f8686062f1974925c3efcdb57e134e37",
"assets/assets/custom_face_resource/4352/gcs06@2x.png": "eaff5b922e07925922bdfaefc28e781f",
"assets/assets/custom_face_resource/4352/gcs14@2x.png": "160783ffe708e9c0bc898bb5c74071da",
"assets/assets/custom_face_resource/4352/gcs08@2x.png": "1e0b9ab84afa11a1e6afae39a282c73f",
"assets/assets/custom_face_resource/4352/gcs16@2x.png": "9dea32f3d207c6c7d5ced29075d9e621",
"assets/assets/custom_face_resource/4352/gcs04@2x.png": "0933b59d6f97f6b2f70bbc05c2c46b47",
"assets/assets/custom_face_resource/4352/gcs01@2x.png": "0f3d1d2fd1bdace295dcf9c68f0826a2",
"assets/assets/custom_face_resource/4352/gcs13@2x.png": "7451dc7333a0d60b4d240d33a977ecea",
"assets/assets/custom_face_resource/4352/gcs11@2x.png": "cd6ece84db447b21e43b2c407fa2ab1f",
"assets/assets/custom_face_resource/4352/gcs03@2x.png": "7c9740b8c9ac8f978cbb255eb93f2969",
"assets/assets/custom_face_resource/4352/menu@2x.png": "2c9b80ed5c6a76d503609cc21214754c",
"assets/assets/custom_face_resource/4352/gcs07@2x.png": "c6120c08136ceb77be2d6c0e3babb45d",
"assets/assets/custom_face_resource/4352/gcs15@2x.png": "1392e8304c4851c2473126aa6be900d9",
"assets/assets/custom_face_resource/4352/gcs09@2x.png": "7fcda31d610e3ca69dcd12295a84fc46",
"assets/assets/custom_face_resource/4352/gcs05@2x.png": "c2e81e2470cd4d498608c9dbf577c9e1",
"assets/assets/icon_copylink.png": "a789d15692ea99dca69f76d90d01b824",
"assets/assets/c2c_conv.png": "a047c6746ec7e2d3b4e98434491a6f5e",
"assets/assets/blackList_brisk.png": "e4cc829ef992dd8096dc513a6c19e80f",
"assets/assets/contact_active.png": "ba040df5d0fe2799e55565d3c4494544",
"assets/assets/black_list.png": "1103d9db959f796e775e947ef23a6935",
"assets/assets/contact.png": "5cd80742438ce60a5f97bbb74c06b78a",
"assets/assets/newContact_brisk.png": "26ac41a0c512376fe5ceeca50ca0a6f9",
"assets/assets/blackList_solemn.png": "d20ab8bc77e19867650ceb3d53bab0eb",
"assets/assets/groupList_bright.png": "f5cf7f211f2a5f9f4bc1397ae96681dd",
"assets/assets/icon_wechat.png": "b7d7556f80676f5a28ff8e7489bd264b",
"assets/assets/newContact.png": "1ddab0b87d835215ede21f5a624a580f",
"assets/assets/logo.png": "af31817d96daf1fdd00f97ab18795f7f",
"assets/assets/groupList_brisk.png": "361ba17749fca88710004f656a769eed",
"assets/assets/groupList.png": "604833e75a5b77d85baa0e3a311b00c1",
"assets/assets/profile.png": "e19056f60bab55299977458f87977ab3",
"assets/assets/im_new_logo.jpg": "eee2a9d5014d4d48cc168d93c237a5bb",
"assets/assets/logo_bottom.png": "fe6f2ed0c73f3610478361b545ea064d",
"assets/assets/add_friend.png": "08c0501cf1b35b956b83832d639bc417",
"assets/assets/newContact_fantasy.png": "e9c1b45962e2e8d646719087d2c33533",
"assets/assets/topic.png": "c7a04bd3a0b10fab69fe646d71cfc89e",
"assets/assets/new_contact.png": "3dbf547cb4cfc3a6d5ab31611edc4315",
"assets/assets/add_group.png": "2d136b24a02617537dc38c08a7537317",
"assets/assets/hero_image.png": "0723105ad52004ef38341529231b142a",
"assets/assets/splash_new.png": "94be6125b482716dccb6f49837f1a7df",
"assets/assets/chat.png": "004bad35afcb298102c1e78ed2aeead9",
"assets/assets/my_group.png": "1d0b410ed374cd2bbaab840eda766e1f",
"assets/assets/trtc_banner.png": "c5fdabf3c670d7f1121c93a969b0f02e",
"assets/assets/blackList_bright.png": "1fe01d62b868aee94cc1cdddf561b0d7",
"assets/assets/groupList_solemn.png": "4c40e7ac096c5b00556de426c04ad7c1",
"assets/assets/group_conv.png": "4e5a5e86554b41086a3a44f65c96b591",
"assets/assets/chat_active.png": "fa25b2f3a0f20b94215e7859e09119e1",
"assets/assets/blackList_fantasy.png": "697686911375f4c4cf75a2fc0b20ac76",
"canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
