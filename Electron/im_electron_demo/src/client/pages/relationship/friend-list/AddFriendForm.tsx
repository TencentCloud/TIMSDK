import { Form, Input, Button, RadioGroup, Radio } from "tea-component";
import React from "react";
import { Form as FinalForm, Field } from "react-final-form";
import { getStatus } from "../../../utils/getStatus";

const validateOldValue = async (value: string, label: string) => {
  if (!value) {
    return `${label}必填`;
  }
};

export interface FormValue {
    userId: string;
    remark: string;
    helloMsg: string;
}

interface CreateGroupFormProps {
  onSubmit: (formValue: FormValue) => Promise<void>;
  onSuccess?: () => void;
  onError?: () => void;
  onClose?: () => void;
}

export const AddFriendForm = (props: CreateGroupFormProps): JSX.Element => {
  const { onSubmit, onSuccess, onError, onClose } = props;

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
      initialValues={{
        userId: '',
        remark: "",
        helloMsg: "",
      }}
    >
      {({ handleSubmit, submitting, validating, values }) => {
        return (
          <form onSubmit={handleSubmit}>
            <Form layout="fixed" style={{ width: "100%" }}>
              <Field
                name="userId"
                disabled={submitting}
                validateOnBlur
                validateFields={[]}
                validate={(value) => validateOldValue(value, "用户ID")}
              >
                {({ input, meta }) => (
                  <Form.Item
                    required
                    label="用户ID"
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
              <Field
                name="remark"
                disabled={submitting}
                validateFields={[]}
              >
                {({ input, meta }) => (
                  <Form.Item
                    label="备注"
                    status={getStatus(meta, validating)}
                    message={
                      getStatus(meta, validating) === "error" && meta.error
                    }
                  >
                    <Input
                      {...input}
                      placeholder="备注"
                      size="full"
                      disabled={submitting}
                    />
                  </Form.Item>
                )}
              </Field>

              <Field
                name="helloMsg"
                disabled={submitting}
                validateFields={[]}
              >
                {({ input, meta }) => (
                  <Form.Item
                    label="加好友附言"
                    status={getStatus(meta, validating)}
                    message={
                      getStatus(meta, validating) === "error" && meta.error
                    }
                  >
                    <Input.TextArea
                      {...input}
                      placeholder="请输入群附言"
                      size="full"
                      disabled={submitting}
                    />
                  </Form.Item>
                )}
              </Field>
            </Form>
            <Form.Action>
              <Button
                className="btn"
                type="primary"
                htmlType="submit"
                loading={submitting}
              >
                添加
              </Button>
              <Button
                className="btn"
                loading={submitting}
                onClick={(e) => {
                  e.stopPropagation();
                  e.preventDefault();
                  onClose();
                }}
              >
                取消
              </Button>
            </Form.Action>
          </form>
        );
      }}
    </FinalForm>
  );
};
