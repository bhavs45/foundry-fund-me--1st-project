//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
        //address vrfCoordinator;
        //uint256 gasPrice;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8; // 2000

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        //vrf address
        //gas price
        // Sepolia ETH / USD Address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        //vrf address
        //gas price
        // Anvil ETH / USD Address
        NetworkConfig memory EthMainnetConfig = NetworkConfig({
            priceFeed: 0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649
        });
        return EthMainnetConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        //price feed address
        //vrf address
        //gas price
        // Anvil ETH / USD Address
        vm.startBroadcast();
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // adress not equal to 0th index ==> we have set the moc price feed address)
        }
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );
        vm.stopBroadcast();
        NetworkConfig memory AnvilConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return AnvilConfig;
    }
}
