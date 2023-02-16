import { Form, Input, Button } from "tea-component";
import React from "react";
import { Form as FinalForm, Field } from "react-final-form";
import { getStatus } from "../../../utils/getStatus";

const reg = /(https?|ftp|file):\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]/;

const validateFaceUrl = (value: string) => {
  // if(!value) {
  //   return '用户头像地址必填';
  // }

  if(value && !reg.test(value)) {
    return 'url不合法';
  }
}

const validateValue = async (value: string,label: string) => {
  if (!value) {
    return `${label}必填`;
  }
};

export interface FormValue {
  groupName: string;
  groupFaceUrl: string;
}

interface Props {
  onSubmit: (formValue: FormValue) => Promise<void>;
  onSuccess?: () => void;
  onError?: () => void;
  onClose?: () => void;
  initialValues: {
    groupName: string;
    groupFaceUrl: string;
  }
}

export const EditGroupBaseInfoForm = (props: Props): JSX.Element => {
  const { onSubmit, onSuccess, onError, initialValues } = props;

  // eslint-disable-next-line
  const _handlerSubmit = async (formValue: FormValue) => {
    try {
      await onSubmit(formValue);
      onSuccess?.();
    } catch (error) {
      onError?.();
    }
  };

  return (
    <FinalForm
      onSubmit={_handlerSubmit}
      initialValuesEqual={() => true}
      initialValues={
        initialValues
      }
    >
      {({ handleSubmit, submitting, validating }) => {
        return (
          <form onSubmit={handleSubmit}>
            <Form layout="fixed" style={{ width: "100%" }}>

            <Field
                name="groupFaceUrl"
                disabled={submitting}
                validateOnBlur
                validateFields={[]}
                validate={validateFaceUrl}
              >
                {({ input, meta }) => (
                  <Form.Item
                    // required
                    label="群头像"
                    status={getStatus(meta, validating)}
                    message={
                      getStatus(meta, validating) === "error" && meta.error
                    }
                  >
                    <Input
                      {...input}
                      placeholder="请输入群头像地址"
                      size="full"
                      disabled={submitting}
                    />
                  </Form.Item>
                )}
              </Field>  

              <Field
                name="groupName"
                disabled={submitting}
                validateOnBlur
                validateFields={[]}
                // validate={(value) => validateValue(value , '群名称')}
              >
                {({ input, meta }) => (
                  <Form.Item
                    // required
                    label="群聊名称"
                    status={getStatus(meta, validating)}
                    message={
                      getStatus(meta, validating) === "error" && meta.error
                    }
                  >
                    <Input
                      {...input}
                      placeholder="请输入"
                      size="full"
                      disabled={submitting}
                    />
                  </Form.Item>
                )}
              </Field>

           
                 
            </Form>
            <Form.Action>
              <Button
                style={{borderRadius: '4px'}}
                type="primary"
                htmlType="submit"
                loading={submitting}
              >
                确认
              </Button>
            </Form.Action>
          </form>
        );
      }}
    </FinalForm>
  );
};
