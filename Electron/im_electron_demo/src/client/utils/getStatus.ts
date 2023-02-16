
export const getStatus = (
  meta: { active: any; touched: any; error: any } | any,
  validating: any
): 'error'| 'success' | 'validating' | undefined => {
  if (meta.active && validating) {
    return 'validating';
  }
  if (!meta.touched) {
    return undefined;
  }
  return meta.error ? 'error' : 'success';
};
