import { Form, Input, Button } from "tea-component";
import React from "react";
import { Form as FinalForm, Field } from "react-final-form";
import { getStatus } from "../../../utils/getStatus";


const validateValue = async (value: string,label: string) => {
  if (!value) {
    return `${label}必填`;
  }
};

export interface FormValue {
  UID: string;
}

interface Props {
  onSubmit: (formValue: FormValue) => Promise<void>;
  onSuccess?: () => void;
  onError?: () => void;
  onClose?: () => void;
}

export const TransferGroupForm = (props: Props): JSX.Element => {
  const { onSubmit, onSuccess, onError } = props;

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
      initialValues={{}}
    >
      {({ handleSubmit, submitting, validating }) => {
        return (
          <form onSubmit={handleSubmit}>
            <Form layout="fixed" style={{ width: "100%" }}>

            <Field
                name="UID"
                disabled={submitting}
                validateOnBlur
                validateFields={[]}
                validate={(value) => validateValue(value , '转让人UID必填')}
              >
                {({ input, meta }) => (
                  <Form.Item
                    required
                    label="转让人UID"
                    status={getStatus(meta, validating)}
                    message={
                      getStatus(meta, validating) === "error" && meta.error
                    }
                  >
                    <Input
                      {...input}
                      placeholder="请输入转让人UID"
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
