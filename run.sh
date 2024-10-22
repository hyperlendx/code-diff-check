echo "install dependencies"
npm install --save-dev prettier prettier-plugin-solidity

echo "remove existing code"
rm -rf aave-v3-core
rm -rf fraxlend
rm -rf hyperlend-core
rm -rf hyperlend-core-isolated

### Core pools

echo "cloning aave-v3-core"
git clone https://github.com/aave/aave-v3-core

#rename files to match hyperlend
mv aave-v3-core/contracts/interfaces/IAaveOracle.sol aave-v3-core/contracts/interfaces/IOracle.sol
mv aave-v3-core/contracts/misc/AaveOracle.sol aave-v3-core/contracts/misc/Oracle.sol
mv aave-v3-core/contracts/misc/AaveProtocolDataProvider.sol aave-v3-core/contracts/misc/ProtocolDataProvider.sol

echo "cloning hyperlend-core"
git clone https://github.com/hyperlendx/hyperlend-core

echo "remove default prettier config"
rm aave-v3-core/.prettierrc
mv hyperlend-core/.prettierrc .prettierrc 

#temp rename .gitignore, so prettier works
mv .gitignore .gitignore-temp

echo "run prettier"
npx prettier --write --plugin=prettier-plugin-solidity 'aave-v3-core/contracts/**/*.sol'
npx prettier --write --plugin=prettier-plugin-solidity 'hyperlend-core/contracts/**/*.sol'

#restore gitignore
mv .gitignore-temp .gitignore

echo "comparing files in contracts/"
diff -r -y --suppress-common-lines aave-v3-core/contracts hyperlend-core/contracts > diffs-core.txt

echo "core diffs have been stored in diffs-core.txt"

### Isolated pools

echo "cloning fraxlend"
git clone https://github.com/FraxFinance/fraxlend/

echo "cloning hyperlend-core-isolated"
git clone https://github.com/hyperlendx/hyperlend-core-isolated

#remove comments
find fraxlend/src/contracts -type f -name "*.sol" -exec sed -i '/^\/\//d' {} +
find hyperlend-core-isolated/contracts -type f -name "*.sol" -exec sed -i '/^\/\//d' {} +

#temp rename .gitignore, so prettier works
mv .gitignore .gitignore-temp

echo "run prettier"
npx prettier --write --plugin=prettier-plugin-solidity 'fraxlend/src/contracts/**/*.sol'
npx prettier --write --plugin=prettier-plugin-solidity 'hyperlend-core-isolated/contracts/**/*.sol'

#restore gitignore
mv .gitignore-temp .gitignore

#rename files to match hyperlend
mkdir fraxlend/contracts
mv fraxlend/src/contracts/FraxlendPair.sol fraxlend/src/contracts/HyperlendPair.sol
mv fraxlend/src/contracts/FraxlendPairAccessControl.sol fraxlend/src/contracts/HyperlendPairAccessControl.sol
mv fraxlend/src/contracts/FraxlendPairAccessControlErrors.sol fraxlend/src/contracts/HyperlendPairAccessControlErrors.sol
mv fraxlend/src/contracts/FraxlendPairConstants.sol fraxlend/src/contracts/HyperlendPairConstants.sol
mv fraxlend/src/contracts/FraxlendPairCore.sol fraxlend/src/contracts/HyperlendPairCore.sol
mv fraxlend/src/contracts/FraxlendPairDeployer.sol fraxlend/src/contracts/HyperlendPairDeployer.sol
mv fraxlend/src/contracts/FraxlendPairRegistry.sol fraxlend/src/contracts/HyperlendPairRegistry.sol
mv fraxlend/src/contracts/FraxlendWhitelist.sol fraxlend/src/contracts/HyperlendWhitelist.sol
mv fraxlend/src/contracts/interfaces/IFraxlendPair.sol fraxlend/src/contracts/interfaces/IHyperlendPair.sol
mv fraxlend/src/contracts/interfaces/IFraxlendPairRegistry.sol fraxlend/src/contracts/interfaces/IHyperlendPairRegistry.sol
mv fraxlend/src/contracts/interfaces/IFraxlendWhitelist.sol fraxlend/src/contracts/interfaces/IHyperlendWhitelist.sol
mv fraxlend/src/contracts/ fraxlend/contracts

echo "comparing files in contracts/"
diff -r -y --suppress-common-lines fraxlend/contracts hyperlend-core-isolated/contracts > diffs-isolated.txt

echo "core-isolated diffs have been stored in diffs-isolated.txt"

#don't exit
read