# openresty-upstream-manager


## upstream

| 方法  | 路径 | 接口名称 | 说明 |
| ---  | ---- | ------ | ---- |
| GET  | [GET /upstream/list]() | upstream 列表 | |
| GET  | [GET /upstream/info]() | upstream 信息 | |
| POST | [POST /upstream/ping]() | ping upstream | |
| POST | [POST /upstream/add]() | 添加 upstream | |
| POST | [POST /upstream/remove]() | 移除 upstream | |
| POST | [POST /upstream/update]() | 更新 upstream | |

### GET /upstream/list

- 接口描述

upstream 列表

- 请求参数

| 属性 | 数据类型 | 长度 | 必填 | 说明 |
| ---- | ---- | ---- | ---- | ---- |


- 响应参数

| 属性 | 数据类型 | 说明 |
| --- | ------- | ---- |


- 响应示例

```json
{
  "data": [],
  "code": 200,
  "message": null
}
```

### POST /upstream/ping


- 接口描述

添加 upstream

- 请求参数

| 属性 | 数据类型 | 长度 | 必填 | 说明 |
| ---- | ---- | ---- | ---- | ---- |

- 请求示例

```json
{}
```

- 响应参数

| 属性 | 数据类型 | 说明 |
| --- | ------- | ---- |

- 响应示例

```json
{
  "data": null,
  "code": 200,
  "message": null
}
```




