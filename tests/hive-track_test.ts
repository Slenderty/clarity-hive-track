import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that members can register",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("hive-track", "register-member", [], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Ensure that proposals can be created by members",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("hive-track", "register-member", [], wallet_1.address),
      Tx.contractCall("hive-track", "create-proposal", [
        types.utf8("Test Proposal"),
        types.utf8("This is a test proposal")
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    assertEquals(block.receipts[1].result.expectOk(), true);
  },
});
