//
//  CustomContactViewController.swift
//  OCKSample
//
//  Created by Brandon Wever on 4/4/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import UIKit
import CareKitStore
import CareKit
import Contacts
import ContactsUI
import ParseSwift
import ParseCareKit
import os.log

class CustomContactViewController: OCKListViewController {

    fileprivate weak var contactDelegate: OCKContactViewControllerDelegate?
    fileprivate var allContacts = [OCKAnyContact]()

    /// The manager of the `Store` from which the `Contact` data is fetched.
    public let storeManager: OCKSynchronizedStoreManager

    /// Initialize using a store manager. All of the contacts in the store manager will be queried and dispalyed.
    ///
    /// - Parameters:
    ///   - storeManager: The store manager owning the store whose contacts should be displayed.
    public init(storeManager: OCKSynchronizedStoreManager) {
        self.storeManager = storeManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.placeholder = " Search Contacts"
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(presentContactsListViewController))

        Task {
            try? await fetchContacts()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        Task {
            try? await fetchContacts()
        }
    }

    @objc private func presentContactsListViewController() {

        let contactPicker = CNContactPickerViewController()
        contactPicker.view.tintColor = self.view.tintColor
        contactPicker.delegate = self
        contactPicker.predicateForEnablingContact = NSPredicate(
          format: "phoneNumbers.@count > 0")
        present(contactPicker, animated: true, completion: nil)
    }

    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    func clearAndKeepSearchBar() {
        clear()
    }

    @MainActor
    func fetchContacts() async throws {
        guard (try? await User.current()) != nil else {
            Logger.contact.error("User not logged in")
            return
        }

        /*
        TODOxx: You should not show any contacts if your user has not completed the
        onboarding task yet. There was a method added recently in Utility.swift to
        assist with this. Use this method here and write a comment and state if
        it's an "instance method" or "type method". If you are trying to copy the
        method to this file, you are using the code incorrectly. Be
        sure to understand the difference between a type method and instance method.
        */

        // swiftlint:disable:next line_length
        // Here, the checkIfOnboardingIsComplete method is a type method, because it was chainbly called from Utility.swift and did not need to have an instance of Utility created to modify the instance's value

        if await Utility.checkIfOnboardingIsComplete() {
            var query = OCKContactQuery(for: Date())
            query.sortDescriptors.append(.familyName(ascending: true))
            query.sortDescriptors.append(.givenName(ascending: true))

            let contacts = try await storeManager.store.fetchAnyContacts(query: query)

            guard let convertedContacts = contacts as? [OCKContact],
                  let personUUIDString = (try? await Utility.getRemoteClockUUID())?.uuidString else {
                Logger.contact.error("Could not convert contacts")
                return
            }

            // TODOx: Modify this filter to not show the contact info for this user
            let filterdContacts = convertedContacts.filter { convertedContact in
                if convertedContact.id != personUUIDString {
                    Logger.contact.info("Contact filtered: \(convertedContact.id)")
                    return true
                } else {
                    return false
                }
            }

            self.clearAndKeepSearchBar()
            self.allContacts = filterdContacts
            self.displayContacts(self.allContacts)

        } else {
            Logger.contact.error("Please complete the survey to see contacts")
        }

    }

    @MainActor
    func displayContacts(_ contacts: [OCKAnyContact]) {
        for contact in contacts {
            let contactViewController = OCKSimpleContactViewController(contact: contact,
                                                                       storeManager: storeManager)
            contactViewController.delegate = self.contactDelegate
            self.appendViewController(contactViewController, animated: false)
        }
    }

    func convertDeviceContacts(_ contact: CNContact) -> OCKAnyContact {

        var convertedContact = OCKContact(id: contact.identifier, givenName: contact.givenName,
                                          familyName: contact.familyName, carePlanUUID: nil)
        convertedContact.title = contact.jobTitle

        var emails = [OCKLabeledValue]()
        contact.emailAddresses.forEach {
            emails.append(OCKLabeledValue(label: $0.label ?? "email", value: $0.value as String))
        }
        convertedContact.emailAddresses = emails

        var phoneNumbers = [OCKLabeledValue]()
        contact.phoneNumbers.forEach {
            phoneNumbers.append(OCKLabeledValue(label: $0.label ?? "phone", value: $0.value.stringValue))
        }
        convertedContact.phoneNumbers = phoneNumbers
        convertedContact.messagingNumbers = phoneNumbers

        if let address = contact.postalAddresses.first {
            convertedContact.address = {
                let newAddress = OCKPostalAddress()
                newAddress.street = address.value.street
                newAddress.city = address.value.city
                newAddress.state = address.value.state
                newAddress.postalCode = address.value.postalCode
                return newAddress
            }()
        }

        return convertedContact
    }
}

extension CustomContactViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Logger.contact.debug("Searching text is '\(searchText)'")

        if searchBar.text!.isEmpty {
            // Show all contacts
            clearAndKeepSearchBar()
            displayContacts(allContacts)
            return
        }

        clearAndKeepSearchBar()

        let filteredContacts = allContacts.filter { (contact: OCKAnyContact) -> Bool in

            if let givenName = contact.name.givenName {
                return givenName.lowercased().contains(searchText.lowercased())
            } else if let familyName = contact.name.familyName {
                return familyName.lowercased().contains(searchText.lowercased())
            } else {
                return false
            }
        }
        displayContacts(filteredContacts)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearAndKeepSearchBar()
        displayContacts(allContacts)
    }
}

extension CustomContactViewController: OCKContactViewControllerDelegate {

    // swiftlint:disable:next line_length
    func contactViewController<C, VS>(_ viewController: CareKit.OCKContactViewController<C, VS>, didEncounterError error: Error) where C: CareKit.OCKContactController, VS: CareKit.OCKContactViewSynchronizerProtocol {
        Logger.contact.error("\(error.localizedDescription)")
    }
}

extension CustomContactViewController: CNContactPickerDelegate {

    @MainActor
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        Task {
            guard (try? await User.current()) != nil else {
                Logger.contact.error("User not logged in")
                return
            }

            let contactToAdd = convertDeviceContacts(contact)

            if !(self.allContacts.contains { $0.id == contactToAdd.id }) {

                // Note - once the functionality is added to edit a contact,
                // let the user potentially edit before the save
                do {
                    _ = try await storeManager.store.addAnyContact(contactToAdd)
                    try? await self.fetchContacts()
                } catch {
                    Logger.contact.error("Could not add contact: \(error.localizedDescription)")
                }
            }
        }
    }

    @MainActor
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        Task {
            guard (try? await User.current()) != nil else {
                Logger.contact.error("User not logged in")
                return
            }

            let newContacts = contacts.compactMap { convertDeviceContacts($0) }

            var contactsToAdd = [OCKAnyContact]()
            for newContact in newContacts where self.allContacts.first(where: { $0.id == newContact.id }) == nil {
                contactsToAdd.append(newContact)
            }

            let immutableContactsToAdd = contactsToAdd

            do {
                _ = try await storeManager.store.addAnyContacts(immutableContactsToAdd)
                try? await self.fetchContacts()
            } catch {
                Logger.contact.error("Could not add contacts: \(error.localizedDescription)")
            }
        }
    }
}
