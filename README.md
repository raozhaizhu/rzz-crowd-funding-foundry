# 🏗️ CrowdFunding DApp (基于 Foundry + Solidity 的众筹合约)

一个最小化的、全链上的众筹合约，使用 Foundry 构建，适合用于 Web3 项目中的募资场景。
A minimal, on-chain crowdfunding smart contract project built with Foundry and Solidity, ideal for Web3 fundraising use cases.

---

## 📚 项目简介 | Project Overview

本项目旨在通过 Solidity 实现一个基础的众筹系统。每个众筹活动可以被创建、查询、分页浏览，并接收来自任意地址的捐赠。
This project implements a basic crowdfunding system in Solidity. Each campaign can be created, queried, paginated, and funded by any address.

---

## ✨ 功能特色 | Features

- ✅ 创建众筹活动 (Create campaigns)
- ✅ 向活动捐款 (Donate to campaigns)
- ✅ 查看单个活动的捐助记录 (View donators & donations)
- ✅ 支持分页查询活动信息 (Paginated campaign retrieval)
- ✅ 支持一次性获取全部活动信息 (Get all campaigns in one call)
- ✅ 严格限制标题和描述长度 (Strict validation on title and description lengths)
- ✅ 支持以太币单位的捐款量统计 (Ether-based donation tracking)

---

## 📦 合约结构 | Contract Structure

| 函数名                                 | 功能说明                 | Description                        |
| -------------------------------------- | ------------------------ | ---------------------------------- |
| `createCampaign(...)`                  | 创建一个新的众筹活动     | Create a new campaign              |
| `donateToCampaign(_id)`                | 向指定 ID 的活动捐款     | Donate ETH to a campaign           |
| `getDonatorsAndDonations(_id)`         | 获取某活动的捐赠者和金额 | Get donators and their donations   |
| `getCampaign(_id)`                     | 获取某个活动的全部数据   | Get full data of a single campaign |
| `getCampaignsPaginated(offset, limit)` | 分页获取活动数据         | Paginated campaign data            |
| `getAllCampaigns()`                    | 获取所有活动信息         | Get all campaigns                  |

---

## 🧪 本地开发与测试 | Local Development & Testing

### 📁 安装依赖 | Install Dependencies

```bash
forge install
```

### 🧊 运行测试 | Run Unit Tests

```bash
forge test -vv
```

### 🔍 查看测试覆盖率 | View Coverage

```bash
forge coverage
```

---

## 🚀 快速开始 | Quick Start

### 1. 克隆项目 | Clone the repo

```bash
git clone https://github.com/yourusername/crowdfunding-foundry.git
cd crowdfunding-foundry
```

### 2. 安装 Foundry（若尚未安装） | Install Foundry (if not installed)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3. 编译合约 | Compile Contracts

```bash
forge build
```

---

## 🧹 项目细节 | Implementation Highlights

- 使用 `struct` 储存众筹活动信息，包含 `title`, `description`, `deadline`, `donations`, `donators` 等字段
- 使用 `mapping(uint256 => Campaign)` 储存所有活动，并通过 `sIdOfCampaign` 管理 ID
- 每笔捐款会自动转账给发起者，并累加捐赠总额
- 严格检查 `deadline`, `title`, `description` 的格式与边界条件

---

## 📄 合约许可协议 | License

[MIT](./LICENSE)

---

## 🙌 鼓励 | Acknowledgement

本项目使用 [Foundry](https://book.getfoundry.sh/) 构建，感谢其提供的强大开发工具集。
This project is powered by Foundry — a blazing fast, modular toolkit for Ethereum application development.

---

## 📬 联系方式 | Contact

如果你对本项目有任何建议或疑问，欢迎提交 issue 或发送邮件@raozhaizhu@gmail.com。
If you have any questions or suggestions, feel free to open an issue or contact me@raozhaizhu@gmail.com.

---
