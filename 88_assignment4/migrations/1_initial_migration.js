var Migrations = artifacts.require("./Migrations.sol");
module.experts = function(deployer){
  deployer.deploy(Migrations);
};
