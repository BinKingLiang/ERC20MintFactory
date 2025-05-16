在以太坊上⽤ ERC20 模拟铭⽂铸造，编写一个可以通过最⼩代理来创建ERC20 的⼯⼚合约，⼯⼚合约包含两个方法：

• deployInscription(string symbol, uint totalSupply, uint perMint, uint price), ⽤户调⽤该⽅法创建 ERC20 Token合约，symbol 表示新创建代币的代号（ ERC20 代币名字可以使用固定的），totalSupply 表示总发行量， perMint 表示单次的创建量， price 表示每个代币铸造时需要的费用（wei 计价）。每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取。

• mintInscription(address tokenAddr) payable: 每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用。

包含测试用例：
费用按比例正确分配到发行者账号及项目方账号。
每次发行的数量正确，且不会超过 totalSupply.
![bb83c847fd17cbd7c7aec80b96346ccb](https://github.com/user-attachments/assets/9b80938b-43e5-4a4b-9d35-27c70c864281)
