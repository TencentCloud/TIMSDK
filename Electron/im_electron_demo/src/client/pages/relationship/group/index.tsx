import React from "react";
import useAsyncRetryFunc from "../../../utils/react-use/useAsyncRetryFunc";
import { getJoinedGroupList } from "../../../api";
import { GroupList } from "./components/GroupList";
import { Title } from "./components/Title";
import "./index.scss";
import { RelationShipItemLoader } from "../../../components/skeleton";
import { DelayLoading } from "../../../components/delayLoading";


export const Group = (): JSX.Element => {
  const { value, loading, retry } = useAsyncRetryFunc(async () => {
    return await getJoinedGroupList();
  }, []);

  return (
      <div className="group">
        <Title onRefresh={retry} />
        <DelayLoading delay={100} minDuration={400} isLoading={loading} fallback={<RelationShipItemLoader />}>
          <GroupList value={value?.filter(item => !item.group_base_info_group_id.includes('meeting-group'))} onRefresh={retry} />
        </DelayLoading>
      </div>
  );
};
