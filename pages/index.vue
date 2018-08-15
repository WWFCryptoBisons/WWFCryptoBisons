<template>
  <section class="container">
    <div>
      <app-logo/>
      <h1 class="title">
        Name a Bison
      </h1>
      <h2 class="subtitle">
        WWF Crypto Bisons project by Blockchain Summer School 2018
      </h2>
      <div>
        <input type="text" placeholder="Choose a name..." name="name" 
          @keyup="updateName" :value="name"/>
      </div>
      <div style="margin-top:20px">
        <input type="text" placeholder="Choose ETH amount..." name="amount" 
          @keyup="updateAmount" :value="amount"/>
      </div>
      <div style="margin-top:20px">
        <button @click="voteForName">Vote for this name</button>
      </div>

      <div>
        <h1>toplist</h1>
        <table border="1" width="100%"> 
          <thead>
            <th>Votes</th>
            <th>Proposed Name</th>
          </thead>
          <tbody>
            <tr v-for="result in arrTopList" :key="result.name">
              <th>{{result.displayAmount}}</th>
              <td>{{result.name}}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>
</template>

<script>
import AppLogo from '~/components/AppLogo.vue'
import _ from 'lodash';
var Web3 = require("web3");
var millify = require("millify");

// var wwfcryptobisons = wwfcryptobisonsContract.new(
//    {
//      from: web3.eth.accounts[0], 
//      data: '0x608060405260028054600160a060020a031916735ba93ce3a2dd006e05f87b65a27d4e5f8d0a4b2017905534801561003657600080fd5b50610422806100466000396000f30060806040526004361061004b5763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630dc960158114610050578063f48c6c60146100fe575b600080fd5b34801561005c57600080fd5b5061006561010b565b604051808060200180602001838103835285818151815260200191508051906020019060200280838360005b838110156100a9578181015183820152602001610091565b50505050905001838103825284818151815260200191508051906020019060200280838360005b838110156100e85781810151838201526020016100d0565b5050505090500194505050505060405180910390f35b610109600435610227565b005b60608060006060806000600180549050935083604051908082528060200260200182016040528015610147578160200160208202803883390190505b50925083604051908082528060200260200182016040528015610174578160200160208202803883390190505b509150600090505b8381101561021c5760008060018381548110151561019657fe5b6000918252602080832090910154835282019290925260400190205483518490839081106101c057fe5b60209081029091010152600180546000918291849081106101dd57fe5b60009182526020808320909101548352820192909252604001902060010154825183908390811061020a57fe5b6020908102909101015260010161017c565b509094909350915050565b60006102316103df565b6040805184815290519081900360200190209150600034116102b457604080517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601d60248201527f546f2063617374206120766f74652c2070617920796f75206d7573742e000000604482015290519081900360640190fd5b600082815260208190526040902060010154156102e7576000828152602081905260409020600101805434019055610338565b6001805480820182557fb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf601839055346020838101918252858452600085815290819052604090208351815590519101555b60025460405173ffffffffffffffffffffffffffffffffffffffff909116903480156108fc02916000818181858888f1935050505015156103da57604080517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601c60248201527f6d6f6e657920636f756c64206e6f7420626520666f7277617264656400000000604482015290519081900360640190fd5b505050565b6040805180820190915260008082526020820152905600a165627a7a723058202dabbf5753b77bcb7ce5e84a2b203f20b813fd45f4073c421bf7bd236526368b0029', 
//      gas: '4700000'
//    }, function (e, contract){
//     console.log(e, contract);
//     if (typeof contract.address !== 'undefined') {
//          console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
//     }
//  })

var wwfcryptobisonsContractInstance;

export default {
  mounted() {
    web3 = new Web3(web3.currentProvider);

    // contract id 0x9c372d4989750ffa8727814b8176646ef94341db
     wwfcryptobisonsContractInstance = new web3.eth.Contract([{"constant":true,"inputs":[],"name":"getVotes","outputs":[{"name":"","type":"bytes32[]"},{"name":"","type":"uint256[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"proposedName","type":"bytes32"}],"name":"voteForName","outputs":[],"payable":true,"stateMutability":"payable","type":"function"}], "0x9c372d4989750ffa8727814b8176646ef94341db");
  
    console.log("wwfcryptobisonsContractInstance", wwfcryptobisonsContractInstance);

    var self = this;
    web3.eth.getAccounts(function(e,accounts){ 
      if (e) {
        throw e;
      }

      self.accounts = accounts
    });

    wwfcryptobisonsContractInstance.methods.getVotes().call().then((results) => {
      console.log("results", results);
      
      var arrTopList = [];

      _.each(results[0], function(result, i) {
        var decodedName = result;
      
        try {
          decodedName = web3.utils.hexToUtf8(decodedName);
        } catch(e) {
          // do nothing
        }

        var amount = parseInt(results[1][i], 10);

        arrTopList.push({
          name: decodedName,
          amount,
          displayAmount: millify(amount)
        });
      });

      self.arrTopList = _.orderBy(arrTopList, ["amount"], ["desc"]);

    });
  },
  methods: {
    updateName (e) {
      this.name = e.target.value;
    },
    updateAmount (e) {
      this.amount = e.target.value;
    },
    voteForName: function(e) {
      if (this.accounts.length === 0) {
        alert("no eth account available, is your metamask running?");
        return;
      }

      console.log("this", this, "e", e);
      // alert("name:"+this.name+" amount"+this.amount);

      console.log(" wwfcryptobisonsContractInstance.methods.voteForName(web3.utils.utf8ToHex(this.name))", wwfcryptobisonsContractInstance.methods.voteForName(web3.utils.utf8ToHex(this.name)));

      wwfcryptobisonsContractInstance.methods.voteForName(web3.utils.utf8ToHex(this.name)).send({
        from: this.accounts[0],
        value: this.amount
      }).then((result) => console.log(result));
    }
  },
  components: {
    AppLogo
  },
  async asyncData({ query, env }) {     
    return {
      accounts: [],
      name: "my name",
      amount: "100000000",
      arrTopList: []
    }
  }
}
</script>

<style>
.container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  /*align-items: center;*/
  padding-top: 50px;
  text-align: center;
}

input[type=text] {
  font-size: 40px;
  padding: 20px;
}

button {
  font-size: 40px;
  padding: 20px;
}

.title {
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}


body {
  background: white url(/static/bison-60592_1920.jpg) no-repeat center center fixed;
  background-size: cover;
}
</style>

