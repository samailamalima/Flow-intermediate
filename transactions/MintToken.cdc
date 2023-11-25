import FungibleToken from 0x05
import MalimaToken from 0x05

transaction (receiver: Address, amount: UFix64) {

    prepare (signer: AuthAccount) {
        // Borrow the MalimaToken admin reference
        let minter = signer.borrow<&MalimaToken.Admin>(from: MalimaToken.AdminStorage)
        ?? panic("You are not the MalimaToken admin")

        // Borrow the receiver's MalimaToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&MalimaToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
        ?? panic("Error: Check your MalimaToken Vault status")
    }

    execute {
        // Mint MalimaTokens using the admin minter reference
        let mintedTokens <- minter.mint(amount: amount)

        // Deposit minted tokens into the receiver's MAlimaToken Vault
        receiverVault.deposit(from: <-mintedTokens)

        log("Minted and deposited Malima tokens successfully")
        log(amount.toString().concat(" Tokens minted and deposited"))
    }
}
