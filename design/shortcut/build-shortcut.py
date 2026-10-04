import plistlib
import uuid


def input_property(*names):
    return {
        "Aggrandizements": [{"PropertyName": name, "Type": "WFPropertyVariableAggrandizement"} for name in names],
        "Type": "ExtensionInput",
    }


def text_token(*names):
    return {
        "Value": {"attachmentsByRange": {"{0, 1}": input_property(*names)}, "string": "￼"},
        "WFSerializationType": "WFTextTokenString",
    }


add_expense = {
    "WFWorkflowActionIdentifier": "dev.horizon.trekcompanion.AddExpenseIntent",
    "WFWorkflowActionParameters": {
        "AppIntentDescriptor": {
            "AppIntentIdentifier": "AddExpenseIntent",
            "BundleIdentifier": "dev.horizon.trekcompanion",
            "Name": "Trek Companion",
        },
        "UUID": str(uuid.uuid4()).upper(),
        "amount": {
            "Value": input_property("Amount"),
            "WFSerializationType": "WFTextTokenAttachment",
        },
        "currencyCode": text_token("Amount"),
        "merchant": text_token("Merchant"),
    },
}

workflow = {
    "WFWorkflowActions": [add_expense],
    "WFWorkflowClientVersion": "5037.109",
    "WFWorkflowMinimumClientVersion": 900,
    "WFWorkflowMinimumClientVersionString": "900",
    "WFWorkflowHasShortcutInputVariables": True,
    "WFWorkflowIcon": {"WFWorkflowIconStartColor": 255, "WFWorkflowIconGlyphNumber": 59511},
    "WFWorkflowImportQuestions": [],
    # No card, category, or merchant filter means Any Card, Any Category, Any Merchant.
    "WFWorkflowTriggers": [{
        "WFTriggerIdentifier": "WFWalletTransactionTrigger",
        "WFTriggerUUID": str(uuid.uuid4()).upper(),
        "WFTriggerSerializedParameters": {
            "__enabled__": 1,
            "__notify__": 0,
            "__show_confirmation__": 0,
        },
    }],
    "WFWorkflowInputContentItemClasses": [
        "WFWalletTransactionContentItem",
        "WFAppContentItem", "WFAppStoreAppContentItem", "WFArticleContentItem", "WFContactContentItem",
        "WFDateContentItem", "WFEmailAddressContentItem", "WFFolderContentItem", "WFGenericFileContentItem",
        "WFImageContentItem", "WFiTunesProductContentItem", "WFLocationContentItem", "WFDCMapsLinkContentItem",
        "WFAVAssetContentItem", "WFPDFContentItem", "WFPhoneNumberContentItem", "WFRichTextContentItem",
        "WFSafariWebPageContentItem", "WFStringContentItem", "WFURLContentItem",
    ],
    "WFWorkflowOutputContentItemClasses": [],
    "WFWorkflowTypes": [],
    "WFQuickActionSurfaces": [],
}

with open("Add to TREK.unsigned.shortcut", "wb") as file:
    plistlib.dump(workflow, file, fmt=plistlib.FMT_BINARY)
