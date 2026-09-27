import plistlib
import uuid


def input_property(name):
    return {
        "Aggrandizements": [{"PropertyName": name, "Type": "WFPropertyVariableAggrandizement"}],
        "Type": "ExtensionInput",
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
        "amount": {"Value": input_property("Amount"), "WFSerializationType": "WFTextTokenAttachment"},
        "merchant": {
            "Value": {"attachmentsByRange": {"{0, 1}": input_property("Merchant")}, "string": "￼"},
            "WFSerializationType": "WFTextTokenString",
        },
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
    "WFWorkflowInputContentItemClasses": [
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
