import FungibleToken from 0x05
import MalimaToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &MalimaToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, MalimaToken.CollectionPublic}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&MalimaToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, MalimaToken.CollectionPublic}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- MalimaToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&MalimaToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, MalimaToken.CollectionPublic}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &MalimaToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&MalimaToken.Vault{FungibleToken.Balance}>()
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &MalimaToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, MalimaToken.CollectionPublic} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&MalimaToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, MalimaToken.CollectionPublic}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if MalimaToken.vaults.contains(checkVault.uuid) {
            log(publicVault?.balance)
            log("This is a MalimaToken vault")
        } else {
            log("This is not a MalimaToken vault")
        }
    }
}
