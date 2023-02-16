import Skeleton from "react-loading-skeleton";
import React from "react";

import "./skeleton.scss";

export const Myloader = () => {
  return (
    <div className="skeleton-content">
      <div className="skeleton-content__conv-list">
        <Skeleton className="search-wrap" width={200} height={30} />
        <Skeleton count={9} height={60} width={232} />
      </div>
    </div>
  );
};

export const MessageLoader = () => {
  return (
    <div className="skeleton-content">
        <div className="skeleton-content__message">
        <div className="skeleton-content__message--header">
            <Skeleton circle height={36} width={36} />
            <Skeleton className="skeleton-content__message--nick-name" width={70} />
        </div>
        <div className="skeleton-content__message--content">
            <div className="skeleton-content__message--item">
            <Skeleton
                className="icon"
                circle
                height={36}
                width={36}
                style={{ marginRight: "8px" }}
            />
            <Skeleton height={84} width={360} />
            </div>
            <div className="skeleton-content__message--item">
            <Skeleton height={84} width={360} />
            <Skeleton
                className="icon"
                circle
                height={36}
                width={36}
                style={{ marginLeft: "8px" }}
            />
            </div>
            <div className="skeleton-content__message--item">
            <Skeleton
                className="icon"
                circle
                height={36}
                width={36}
                style={{ marginRight: "8px" }}
            />
            <Skeleton height={44} width={150} />
            </div>
            <div className="skeleton-content__message--item">
            <Skeleton height={44} width={94} />
            <Skeleton
                className="icon"
                circle
                height={36}
                width={36}
                style={{ marginLeft: "8px" }}
            />
            </div>
        </div>
        </div>
    </div>
  );
};

export const RelationShipItemLoader = (): JSX.Element => (
  <div className="relationship-item-loader">
      <div className="relationship-item-loader__item">
        <span className="relationship-item-loader__item--avatar">
            <Skeleton
                className="icon"
                circle
                height={40}
                width={40}
                style={{ marginRight: "8px" }}
            />
            <Skeleton height={18} width={180} />
        </span>
        <Skeleton height={18} width={70} />
      </div>
      <div className="relationship-item-loader__item">
        <span className="relationship-item-loader__item--avatar">
            <Skeleton
                className="icon"
                circle
                height={40}
                width={40}
                style={{ marginRight: "8px" }}
            />
            <Skeleton height={18} width={180} />
        </span>
        <Skeleton height={18} width={70} />
      </div>
      <div className="relationship-item-loader__item">
        <span className="relationship-item-loader__item--avatar">
            <Skeleton
                className="icon"
                circle
                height={40}
                width={40}
                style={{ marginRight: "8px" }}
            />
            <Skeleton height={18} width={180} />
        </span>
        <Skeleton height={18} width={70} />
      </div>
  </div>
)
