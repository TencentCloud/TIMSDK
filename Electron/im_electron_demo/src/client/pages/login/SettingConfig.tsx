import React, { useState, useEffect } from "react";
import Store from 'electron-store';
import { ipcRenderer } from 'electron';
import { useDispatch } from 'react-redux';
import {
    Modal,
    Form,
    Input,
    Card,
    Button,
    Icon,
} from "tea-component";

import { updateSettingConfig } from '../../store/actions/config';
import { DEFAULT_SETTING_CONFIG } from '../../constants';
import { isWin } from '../../utils/tools';

// eslint-disable-next-line
import { Form as FinalForm, Field } from "react-final-form";

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const store = new Store();
const clearTmp = {
    userId: '',
    sdkappId: '',
    userSig: '',
    addressIp: '',
    port: '',
    publicKey: ''
}

function getStatus(meta, validating) {
    if (meta.active && validating) {
        return "validating";
    }
    if (!meta.touched) {
        return null;
    }
    return meta.error ? "error" : "success";
}


export const SettingConfig = () => {
    const [showModal, setShowModal ] = useState(false);
    const [defaultConfig, setDefaultConfig ] = useState(DEFAULT_SETTING_CONFIG);
    const dispatch = useDispatch();

    async function onSubmit(values) {
        await ipcRenderer.invoke('re-create-main-instance', values.sdkappId);
        setShowModal(false);
        store.set('setting-config', values);
        dispatch(updateSettingConfig({
            ...values,
            addressIp: values.addressIp ?? '',
            port: values.port ?? '',
            publicKey: values.publicKey ?? ''
        }));
    }

    const clearConfig = () => {
        dispatch(updateSettingConfig(clearTmp));
        setDefaultConfig(clearTmp)
        store.delete('setting-config');
    }

    useEffect(() => {
        const configSetting = store.get('setting-config') as State.SettingConfig;
        // @ts-ignore
        if(configSetting) {
            setDefaultConfig(configSetting);
            dispatch(updateSettingConfig(configSetting));
        } else {
            // setShowModal(true);
        }
    }, []);

    useEffect(() => {
        if(showModal) {
            const configSetting = store.get('setting-config') as State.SettingConfig;
            setDefaultConfig(configSetting);
        }

    }, [showModal]);

    const handleOpenSettingModal = () => setShowModal(true);

    const topStyle = isWin ? '35px' : '10px';

    return (
        <div>
            <Icon style={{position: 'fixed', right: '10px', top: topStyle , zIndex: 10000}} type="setting" size="l" onClick={handleOpenSettingModal} />
            <Modal onClose={()=>{setShowModal(false)}}  visible={showModal} >
                <Modal.Body>
                    <div className="example-stage">
                        <Card>
                            <Card.Body>
                                <FinalForm
                                    initialValues={defaultConfig}
                                    onSubmit={onSubmit}
                                >
                                    {({ handleSubmit, validating, submitting }) => {
                                        return (
                                            <form onSubmit={handleSubmit}>
                                                <Form.Title>基础配置 (仅密码登录有效)</Form.Title>
                                                <Form>
                                                    <Field
                                                        name="sdkappId"
                                                        validateOnBlur
                                                        validateFields={[]}
                                                        validate={async value => {
                                                            await sleep(1500);
                                                            return !value ? "必填项" : undefined;
                                                        }}
                                                    >
                                                        {({ input, meta }) => (
                                                            <Form.Item
                                                                label="sdkAppId"
                                                                status={getStatus(meta, validating)}
                                                                message={
                                                                    getStatus(meta, validating) === "error" &&
                                                                    meta.error
                                                                }
                                                            >
                                                                <Input
                                                                    {...input}
                                                                    autoComplete="off"
                                                                    size="full"
                                                                    placeholder="请填写sdkappid"
                                                                />
                                                            </Form.Item>
                                                        )}
                                                    </Field>
                                                    <Field
                                                        name="userId"
                                                        validateOnBlur
                                                        validateFields={[]}
                                                        validate={async value => {
                                                            await sleep(1500);
                                                            return !value ? "必填项" : undefined;
                                                        }}
                                                    >
                                                        {({ input, meta }) => (
                                                            <Form.Item
                                                                label="userId"
                                                                status={getStatus(meta, validating)}
                                                                message={
                                                                    getStatus(meta, validating) === "error" &&
                                                                    meta.error
                                                                }
                                                            >
                                                                <Input
                                                                    {...input}
                                                                    size="full"
                                                                    autoComplete="off"
                                                                    placeholder="请填写userId"
                                                                />
                                                            </Form.Item>
                                                        )}
                                                    </Field>
                                                    <Field
                                                        name="userSig"
                                                        validateOnBlur
                                                        validateFields={[]}
                                                        validate={async value => {
                                                            await sleep(1500);
                                                            return !value ? "必填项" : undefined;
                                                        }}
                                                    >
                                                        {({ input, meta }) => (
                                                            <Form.Item
                                                                label="userSig"
                                                                status={getStatus(meta, validating)}
                                                                message={
                                                                    getStatus(meta, validating) === "error" &&
                                                                    meta.error
                                                                }
                                                            >
                                                                <Input
                                                                    {...input}
                                                                    autoComplete="off"
                                                                    size="full"
                                                                    placeholder="请填写userSig"
                                                                />
                                                            </Form.Item>
                                                        )}
                                                    </Field>
                                                </Form>
                                                <hr />
                                                <Form.Title>私有化配置 (仅密码登录有效)</Form.Title>
                                                <Form>
                                                    <Field
                                                        name="addressIp"
                                                    >
                                                        {({ input, meta }) => (
                                                            <Form.Item
                                                                label="addressIp"
                                                                status={getStatus(meta, validating)}
                                                                message={
                                                                    getStatus(meta, validating) === "error" &&
                                                                    meta.error
                                                                }
                                                            >
                                                                <Input
                                                                    {...input}
                                                                    size="full"
                                                                    placeholder="请填写address_ip"
                                                                />
                                                            </Form.Item>
                                                        )}
                                                    </Field>
                                                    <Field
                                                        name="port"
                                                    >
                                                        {({ input, meta }) => (
                                                            <Form.Item
                                                                label="port"
                                                                status={getStatus(meta, validating)}
                                                                message={
                                                                    getStatus(meta, validating) === "error" &&
                                                                    meta.error
                                                                }
                                                            >
                                                                <Input
                                                                    size="full"
                                                                    {...input}
                                                                    placeholder="请填写address_port"
                                                                />
                                                            </Form.Item>
                                                        )}
                                                    </Field>
                                                    <Field
                                                        name="publicKey"
                                                    >
                                                        {({ input, meta }) => (
                                                            <Form.Item
                                                                label="publicKey"
                                                                status={getStatus(meta, validating)}
                                                                message={
                                                                    getStatus(meta, validating) === "error" &&
                                                                    meta.error
                                                                }
                                                            >
                                                                <Input
                                                                    {...input}
                                                                    size="full"
                                                                    placeholder="请填写public Key"
                                                                />
                                                            </Form.Item>
                                                        )}
                                                    </Field>
                                                </Form>
                                                <Form.Action>
                                                    <Button
                                                        type="primary"
                                                        htmlType="submit"
                                                        loading={submitting}
                                                    >
                                                        提交
                                                    </Button>
                                                    <Button onClick={clearConfig}>清除配置</Button>
                                                </Form.Action>
                                            </form>
                                        );
                                    }}
                                </FinalForm>
                            </Card.Body>
                        </Card>
                    </div>
                </Modal.Body>
            </Modal>
        </div>
    )
};