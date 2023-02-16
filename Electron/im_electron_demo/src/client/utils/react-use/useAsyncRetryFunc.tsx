import { DependencyList, useEffect } from "react";
import { useAsyncFn } from "./useAsyncFun";

type FunctionReturningPromise = (...args: any[]) => Promise<any>;

export default function useAsyncRetryFunc<T extends FunctionReturningPromise>(
  fn: T,
  deps: DependencyList = []
) {
  /* eslint-disable */
  const [state, fetchData] = useAsyncFn(fn, deps, {
    loading: true,
  });

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return {
    ...state,
    retry: fetchData,
  };
}
