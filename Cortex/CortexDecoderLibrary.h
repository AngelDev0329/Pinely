//
//  CortexDecoderLibrary.h
//  CortexDecoderLibrary
//
//  Copyright (c) 2014-2019 The Code Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Symbology Properties -
/*!
 This protocol is implmented by all symbology settings objects.
 */
@protocol CD_SymbologyProperties <NSObject>

/*!
 This method is used to save the property values.
 */
@required
-(void)saveProperties;

/*!
 @brief This method is used to save default values for all Symbology properties.
 
 @remarks For inital SDK initialization, SDK will set all licensed Symbology and Performance features to default values.
 */
@optional
-(void)setDefaultSettings;

/*!
 This method is used to retrieve singleton object for the class.
 */
@optional
+(id)sharedObject;

/*!
 @brief This method is used to reload last used setting for the Symbology.
 
 @remarks SDK uses this API for all licensed Symbology and Performance features when API validateLicenseKey is used.
 */
@optional
-(void)retrieveSettings;

@end

//#################################################
/*!
 Properties for the Code 128 symbology.
 */
@interface CD_Code128Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) int minimumLength;

/*! This method is used to enable/disable Code 128 Symbology. */
-(void)enableCode128:(BOOL)enabled;
/*!This method is used to set minimum length for barcode to be decoded.
 
 @remarks Defaults to 1.
 */
-(void)changeMinimumLength:(int)minimumLength;
/*! This method is used to retrieve if Code 128 is enable/disable. */
-(BOOL)getCode128Setting;
/*! This method is used to retrieve Minimum Length value for Code 128. */
-(int)getMinimumLengthSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Code 93 symbology.
 */
@interface CD_Code93Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) int minimumLength;

/*! This method is used to enable/disable Code 93 Symbology. */
-(void)enableCode93:(BOOL)enabled;
/*!This method is used to set minimum length for barcode to be decoded.
 
 @remarks Defaults to 1.
 */
-(void)changeMinimumLength:(int)minimumLength;
/*! This method is used to retrieve if Code 93 is enable/disable. */
-(BOOL)getCode93Setting;
/*! This method is used to retrieve Minimum Length value for Code 93. */
-(int)getMinimumLengthSetting;

@end
//#################################################
//#################################################
/*!
 Properties for the Composite Code symbology.
 */
@interface CD_CompositeCodeProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL componentAEnabled;
@property (assign,nonatomic) BOOL componentBEnabled;
@property (assign,nonatomic) BOOL componentCEnabled;

/*! This method is used to enable/disable all Composite Code Symbologies.
 
 @remarks Enables all Sub-Symbologies.
 */
-(void)enableCompositeCodes:(BOOL)enabled;
/*! This method is used to enable/disable Composite Code - Component A Symbology. */
-(void)enableCompositeCodeComponentA:(BOOL)componentAEnabled;
/*! This method is used to enable/disable Composite Code - Component B Symbology. */
-(void)enableCompositeCodeComponentB:(BOOL)componentBEnabled;
/*! This method is used to enable/disable Composite Code - Component C Symbology. */
-(void)enableCompositeCodeComponentC:(BOOL)componentCEnabled;
/*! This method is used to retrieve if any Composite Code is enable/disable.
 
 @remarks Returns YES if any one of the Symbologies are enabled.
 */
-(BOOL)getCompositeCodesSetting;
/*! This method is used to retrieve if Composite Code - Component A is enable/disable. */
-(BOOL)getCompositeCodeComponentASetting;
/*! This method is used to retrieve if Composite Code - Component B is enable/disable. */
-(BOOL)getCompositeCodeComponentBSetting;
/*! This method is used to retrieve if Composite Code - Component C is enable/disable. */
-(BOOL)getCompositeCodeComponentCSetting;

@end
//#################################################
//#################################################
/*!
 Properties for the Code 49 symbology.
 */
@interface CD_Code49Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Code 49 Symbology. */
-(void)enableCode49:(BOOL)enabled;
/*! This method is used to retrieve if Code 49 is enable/disable. */
-(BOOL)getCode49Setting;

@end
//#################################################

//#################################################
/*!
 Properties for the BC412 symbology.
 */
@interface CD_BC412Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL enableReverseDecoding;

/*! This method is used to enable/disable BC 412 Symbology. */
-(void)enableBC412:(BOOL)enabled;
/*! This method is used to enable/disable Reverse Decoding setting. */
-(void)enableReverseDecoding:(BOOL)enableReverseDecoding;
/*! This method is used to retrieve if BC 412 is enable/disable. */
-(BOOL)getBC412Setting;
/*! This method is used to retrieve if Reverse Decoding setting is enable/disable. */
-(BOOL)getReverseDecodingSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Code 39 symbology.
 */
@interface CD_Code39Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_Code39PropertiesChecksum
 
 @brief Represents information about Code 39 checksum supported by CortexDecoder.
 */
typedef enum {
    CD_Code39PropertiesChecksum_Disabled,
    CD_Code39PropertiesChecksum_Enabled,
    CD_Code39PropertiesChecksum_EnabledStripCheckCharacter,
} CD_Code39PropertiesChecksum;


@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_Code39PropertiesChecksum checksumProperties;
@property (assign,nonatomic) BOOL asciiModeEnabled;
@property (assign,nonatomic) BOOL stripStartStopCharactersEnabled;
@property (assign,nonatomic) int minimumLength;

/*! This method is used to enable/disable Code 39 Symbology. */
-(void)enableCode39:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_Code39PropertiesChecksum)checksumProperties;
/*! This method is used to enable/disable ASCII Mode setting. */
-(void)enableAsciiMode:(BOOL)asciiModeEnabled;
/*! This method is used to enable/disable Strip Start Stop Character setting. */
-(void)enableStripStartStopCharacters:(BOOL)stripStartStopCharactersEnabled;
/*!This method is used to set minimum length for barcode to be decoded.
 
 @remarks Defaults to 1.
 */
-(void)changeMinimumLength:(int)minimumLength;
/*! This method is used to retrieve if Code 39 is enable/disable. */
-(BOOL)getCode39Setting;
/*! This method is used to retrieve Checksum setting. */
-(CD_Code39PropertiesChecksum)getChecksumSetting;
/*! This method is used to retrieve ASCII Mode setting. */
-(BOOL)getASCIIModeSetting;
/*! This method is used to retrieve Strip Start Stop Character setting. */
-(BOOL)getStripStartStopCharactersSetting;
/*! This method is used to retrieve Minimum Length value for Code 39. */
-(int)getMinimumLengthSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Interleaved 2 of 5 symbology.
 */
@interface CD_Interleaved2of5Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_Interleaved2of5PropertiesChecksum
 
 @brief Represents information about Interleaved 2 Of 5 checksum supported by CortexDecoder.
 */
typedef enum {
    CD_Interleaved2of5PropertiesChecksum_Disabled,
    CD_Interleaved2of5PropertiesChecksum_Enabled,
    CD_Interleaved2of5PropertiesChecksum_EnabledStripCheckCharacter,
} CD_Interleaved2of5PropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_Interleaved2of5PropertiesChecksum checksumProperties;
@property (assign,nonatomic) int lengthPlusQuietZone;   //Set Minimum length for barcode including Quiet zone if any. Defaults to 2.
@property (assign,nonatomic) BOOL rejectPartialDecode;
@property (assign,nonatomic) BOOL quietZone;

/*! This method is used to enable/disable Interleaved 2 Of 5 Symbology. */
-(void)enableInterleaved2Of5:(BOOL)enabled;
/*! This method is used to enable/disable Reject Partial Decode setting. */
-(void)enableRejectPartialDecode:(BOOL)rejectPartialDecode;
/*!This method is used to set Minimum Length Plus Quite Zone for barcode to be decoded.
 
 @remarks Defaults to 8.
 */
-(void)changeLengthPlusQuietZone:(int)lengthPlusQuietZone;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_Interleaved2of5PropertiesChecksum)checksumProperties;
/*! This method is used to enable/disable Quite Zone setting. */
-(void)enableQuietZone:(BOOL)quietZone;
/*! This method is used to retrieve if Interleaved 2 Of 5 is enable/disable. */
-(BOOL)getInterleaved2Of5Setting;
/*! This method is used to retrieve Reject Partial Decode setting. */
-(BOOL)getRejectPartialDecodeSetting;
/*! This method is used to retrieve Minimum Length Plus Quite Zone value for Interleaved 2 Of 5. */
-(int)getLengthPlusQuietZoneSetting;
/*! This method is used to retrieve Checksum setting. */
-(CD_Interleaved2of5PropertiesChecksum)getChecksumSetting;
/*! This method is used to retrieve Quite Zone setting. */
-(BOOL)getQuietZoneSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Codabar symbology.
 */
@interface CD_CodabarProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_CodabarPropertiesChecksum
 
 @brief Represents information about Codabar checksum supported by CortexDecoder.
 */
typedef enum {
    CD_CodabarPropertiesChecksum_Disabled,
    CD_CodabarPropertiesChecksum_Enabled,
    CD_CodabarPropertiesChecksum_EnabledStripCheckCharacter,
} CD_CodabarPropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_CodabarPropertiesChecksum checksumProperties;
@property (assign,nonatomic) BOOL stripStartStopCharactersEnabled;
@property (assign,nonatomic) int minimumLength;

/*! This method is used to enable/disable Codabar Symbology. */
-(void)enableCodabar:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeCodabarChecksumProperties:(CD_CodabarPropertiesChecksum)checksumProperties;
/*! This method is used to enable/disable Strip Start Stop Characters setting. */
-(void)enableStripStartStopCharacters:(BOOL)stripStartStopCharactersEnabled;
/*!This method is used to set minimum length for barcode to be decoded.
 
 @remarks Defaults to 4.
 */
-(void)changeMinimumLength:(int)minimumLength;
/*! This method is used to retrieve if Codabar is enable/disable. */
-(BOOL)getCodabarSettting;
/*! This method is used to retrieve Checksum setting. */
-(CD_CodabarPropertiesChecksum)getChecksumSetting;
/*! This method is used to retrieve Strip Start Stop Characters setting. */
-(BOOL)getStripStartStopCharactersSetting;
/*! This method is used to retrieve Minimum Length value. */
-(int)getMinimumLengthSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the UPCA symbology.
 */
@interface CD_UPCAProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL convertToEAN13Enabled;
@property (assign,nonatomic) BOOL stripUPCASystemNumberDigitEnabled;
@property (assign,nonatomic) BOOL stripCheckDigitEnabled;
@property (assign,nonatomic) BOOL supplement2DigitEnable;
@property (assign,nonatomic) BOOL supplement5DigitEnable;
@property (assign,nonatomic) BOOL supplementAddSpace;
@property (assign,nonatomic) BOOL supplementRequired;       //

/*! This method is used to enable/disable UPCA Symbology. */
-(void)enableUPCA:(BOOL)enabled;
/*! This method is used to enable/disable Convert To EAN13 setting. */
-(void)enableConvertToEAN13:(BOOL)convertToEAN13Enabled;
/*! This method is used to enable/disable Strip UPCA System Number Digit setting. */
-(void)enableStripUPCASystemNumberDigit:(BOOL)stripUPCASystemNumberDigitEnabled;
/*! This method is used to enable/disable Strip Check Digit setting. */
-(void)enableStripCheckDigit:(BOOL)stripCheckDigitEnabled;
/*!
 @brief This method is used to enable/disable Supplement 2 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement2Digit:(BOOL)supplement2DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement 5 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement5Digit:(BOOL)supplement5DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement Add Space setting.
 
 @discussion It adds space between normal barcode data and 2/5 digit supplemental barcode data.
 */
-(void)enableSupplementAddSpace:(BOOL)supplementAddSpace;
/*!
 @brief This method is used to enable/disable Supplement Required setting.
 
 @discussion Does not decode barcode without either 2/5 digit supplement.
 */
-(void)enableSupplementRequired:(BOOL)supplementRequired;
/*! This method is used to retrieve if UPCA is enable/disable. */
-(BOOL)getUPCASetting;
/*! This method is used to retrieve Convert To EAN13 setting. */
-(BOOL)getConvertToEAN13Setting;
/*! This method is used to retrieve Strip UPCA System Number Digit setting. */
-(BOOL)getStripUPCASystemNumberDigitSetting;
/*! This method is used to retrieve Strip Check Digit setting. */
-(BOOL)getStripCheckDigitSetting;
/*! This method is used to retrieve Supplement 2 Digit setting. */
-(BOOL)getSupplement2DigitSetting;
/*! This method is used to retrieve Supplement 5 Digit setting. */
-(BOOL)getSupplement5DigitSetting;
/*! This method is used to retrieve Supplement Add Space setting. */
-(BOOL)getSupplementAddSpaceSetting;
/*! This method is used to retrieve Supplement Required setting. */
-(BOOL)getSupplementRequiredSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the UPCE symbology.
 */
@interface CD_UPCEProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL expansionEnabled;
@property (assign,nonatomic) BOOL stripUPCESystemNumberDigitEnabled;
@property (assign,nonatomic) BOOL stripCheckDigitEnabled;
@property (assign,nonatomic) BOOL supplement2DigitEnable;
@property (assign,nonatomic) BOOL supplement5DigitEnable;
@property (assign,nonatomic) BOOL supplementAddSpace;
@property (assign,nonatomic) BOOL supplementRequired;
@property (assign,nonatomic) BOOL enableUPCESystem1;

/*! This method is used to enable/disable UPCE Symbology. */
-(void)enableUPCE:(BOOL)enabled;
/*! This method is used to enable/disable Expansion setting. */
-(void)enableExpansion:(BOOL)expansionEnabled;
/*! This method is used to enable/disable Strip UPCE System Number Digit setting. */
-(void)enableStripUPCESystemNumberDigit:(BOOL)stripUPCESystemNumberDigitEnabled;
/*! This method is used to enable/disable Strip Check Digit setting. */
-(void)enableStripCheckDigit:(BOOL)stripCheckDigitEnabled;
/*!
 @brief This method is used to enable/disable Supplement 2 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement2Digit:(BOOL)supplement2DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement 5 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement5Digit:(BOOL)supplement5DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement Add Space setting.
 
 @discussion It adds space between normal barcode data and 2/5 digit supplemental barcode data.
 */
-(void)enableSupplementAddSpace:(BOOL)supplementAddSpace;
/*!
 @brief This method is used to enable/disable Supplement Required setting.
 
 @discussion Does not decode barcode without either 2/5 digit supplement.
 */
-(void)enableSupplementRequired:(BOOL)supplementRequired;
/*!
 @brief This method is used to enable/disable UPCE System 1 barcodes.
 
 @remarks Default is enable.
*/
-(void)enableEnableUPCESystem1:(BOOL)enableUPCESystem1;
/*! This method is used to retrieve if UPCE is enable/disable. */
-(BOOL)getUPCESetting;
/*! This method is used to retrieve Expansion setting. */
-(BOOL)getExpansionSetting;
/*! This method is used to retrieve Strip UPCE System Number Digit setting. */
-(BOOL)getStripUPCESystemNumberDigitSetting;
/*! This method is used to retrieve Strip Check Digit setting. */
-(BOOL)getStripCheckDigitSetting;
/*! This method is used to retrieve Supplement 2 Digit setting. */
-(BOOL)getSupplement2DigitSetting;
/*! This method is used to retrieve Supplement 5 Digit setting. */
-(BOOL)getSupplement5DigitSetting;
/*! This method is used to retrieve Supplement Add Space setting. */
-(BOOL)getSupplementAddSpaceSetting;
/*! This method is used to retrieve Supplement Required setting. */
-(BOOL)getSupplementRequiredSetting;
/*! This method is used to retrieve UPCE System 1 setting. */
-(BOOL)getUPCSystem1Setting;

@end
//#################################################

//#################################################
/*!
 Properties for the EAN 13 symbology.
 */
@interface CD_EAN13Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL stripCheckDigitEnabled;
@property (assign,nonatomic) BOOL supplement2DigitEnable;
@property (assign,nonatomic) BOOL supplement5DigitEnable;
@property (assign,nonatomic) BOOL supplementAddSpace;
@property (assign,nonatomic) BOOL supplementRequired;

/*! This method is used to enable/disable EAN13 Symbology. */
-(void)enableEAN13:(BOOL)enabled;
/*! This method is used to enable/disable Strip Check Digit setting. */
-(void)enableStripCheckDigit:(BOOL)stripCheckDigitEnabled;
/*!
 @brief This method is used to enable/disable Supplement 2 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement2Digit:(BOOL)supplement2DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement 5 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement5Digit:(BOOL)supplement5DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement Add Space setting.
 
 @discussion It adds space between normal barcode data and 2/5 digit supplemental barcode data.
 */
-(void)enableSupplementAddSpace:(BOOL)supplementAddSpace;
/*!
 @brief This method is used to enable/disable Supplement Required setting.
 
 @discussion Does not decode barcode without either 2/5 digit supplement.
 */
-(void)enableSupplementRequired:(BOOL)supplementRequired;
/*! This method is used to retrieve if EAN13 is enable/disable. */
-(BOOL)getEAN13Setting;
/*! This method is used to retrieve Strip Check Digit setting. */
-(BOOL)getStripCheckDigitSetting;
/*! This method is used to retrieve Supplement 2 Digit setting. */
-(BOOL)getSupplement2DigitSetting;
/*! This method is used to retrieve Supplement 5 Digit setting. */
-(BOOL)getSupplement5DigitSetting;
/*! This method is used to retrieve Supplement Add Space setting. */
-(BOOL)getSupplementAddSpaceSetting;
/*! This method is used to retrieve Supplement Required setting. */
-(BOOL)getSupplementRequiredSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the EAN 8 symbology.
 */
@interface CD_EAN8Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL convertToEAN13Enabled;
@property (assign,nonatomic) BOOL stripCheckDigitEnabled;
@property (assign,nonatomic) BOOL supplement2DigitEnable;
@property (assign,nonatomic) BOOL supplement5DigitEnable;
@property (assign,nonatomic) BOOL supplementAddSpace;
@property (assign,nonatomic) BOOL supplementRequired;

/*! This method is used to enable/disable EAN8 Symbology. */
-(void)enableEAN8:(BOOL)enabled;
/*! This method is used to enable/disable Strip Check Digit setting. */
-(void)enableStripCheckDigit:(BOOL)stripCheckDigitEnabled;
/*! This method is used to enable/disable Convert To EAN13 setting. */
-(void)enableConvertToEAN13:(BOOL)convertToEAN13Enabled;
/*!
 @brief This method is used to enable/disable Supplement 2 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement2Digit:(BOOL)supplement2DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement 5 Digit setting.
 
 @remarks Default is disable.
 */
-(void)enableSupplement5Digit:(BOOL)supplement5DigitEnable;
/*!
 @brief This method is used to enable/disable Supplement Add Space setting.
 
 @discussion It adds space between normal barcode data and 2/5 digit supplemental barcode data.
 */
-(void)enableSupplementAddSpace:(BOOL)supplementAddSpace;
/*!
 @brief This method is used to enable/disable Supplement Required setting.
 
 @discussion Does not decode barcode without either 2/5 digit supplement.
 */
-(void)enableSupplementRequired:(BOOL)supplementRequired;
/*! This method is used to retrieve if EAN8 is enable/disable. */
-(BOOL)getEAN8Setting;
/*! This method is used to retrieve Strip Check Digit setting. */
-(BOOL)getStripCheckDigitSetting;
/*! This method is used to retrieve Convert To EAN13 setting. */
-(BOOL)getConvertToEAN13Setting;
/*! This method is used to retrieve Supplement 2 Digit setting. */
-(BOOL)getSupplement2DigitSetting;
/*! This method is used to retrieve Supplement 5 Digit setting. */
-(BOOL)getSupplement5DigitSetting;
/*! This method is used to retrieve Supplement Add Space setting. */
-(BOOL)getSupplementAddSpaceSetting;
/*! This method is used to retrieve Supplement Required setting. */
-(BOOL)getSupplementRequiredSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the GS1 DataBar 14 symbology.
 */
@interface CD_GS1DataBar14Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL omniTruncatedDecodingEnabled;
@property (assign,nonatomic) BOOL limitedDecodingEnabled;
@property (assign,nonatomic) BOOL stackedDecodingEnabled;
@property (assign,nonatomic) BOOL expandedDecodingEnabled;
@property (assign,nonatomic) BOOL expandedStackDecodingEnabled;
@property (assign,nonatomic) BOOL ccaDecodingEnabled;/*This property is deprecated.Enable CCA using Composite Code properties */
@property (assign,nonatomic) BOOL ccbDecodingEnabled;/*This property is deprecated.Enable CCB using Composite Code properties */
@property (assign,nonatomic) BOOL cccDecodingEnabled;/*This property is deprecated.Enable CCC using Composite Code properties */

/*!
 @brief This method is used to enable/disable all GS1 DataBar 14 Symbologies.
 
 @remarks Enables all Sub-Symbologies.
 */
-(void)enableGS1DataBar14Codes:(BOOL)enabled;
/*! This method is used to enable/disable Omni Truncated Decoding. */
-(void)enableOmniTruncatedDecoding:(BOOL)omniTruncatedDecodingEnabled;
/*! This method is used to enable/disable Limited Decoding. */
-(void)enableLimitedDecoding:(BOOL)limitedDecodingEnabled;
/*! This method is used to enable/disable Stacked Decoding. */
-(void)enableStackedDecoding:(BOOL)stackedDecodingEnabled;
/*! This method is used to enable/disable Expanded Decoding. */
-(void)enableExpandedDecoding:(BOOL)expandedDecodingEnabled;
/*! This method is used to enable/disable Expanded Stack Decoding. */
-(void)enableExpandedStackDecoding:(BOOL)expandedStackDecodingEnabled;
/*! This method is used to retrieve if any GS1 DataBar 14 is enable/disable. */
-(BOOL)getGS1DataBar14CodesSetting;
/*!
 @brief This method is used to retrieve if Omni Truncated Decoding is enable/disable.
 
 @remarks Returns YES if any one of the Symbologies are enabled.
 */
-(BOOL)getOmniTruncatedDecodingSetting;
/*! This method is used to retrieve if Limited Decoding is enable/disable. */
-(BOOL)getLimitedDecodingSetting;
/*! This method is used to retrieve if Stacked Decoding is enable/disable. */
-(BOOL)getStackedDecodingSetting;
/*! This method is used to retrieve if Expanded Decoding is enable/disable. */
-(BOOL)getExpandedDecodingSetting;
/*! This method is used to retrieve if Expanded Stack Decoding is enable/disable. */
-(BOOL)getExpandedStackDecodingSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Code 11 symbology.
 */
@interface CD_Code11Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_Code11PropertiesChecksum
 
 @brief Represents information about Code 11 checksum supported by CortexDecoder.
 */
typedef enum {
    CD_Code11PropertiesChecksum_Disabled,
    CD_Code11PropertiesChecksum_EnabledDigit1,
    CD_Code11PropertiesChecksum_EnabledDigit2
} CD_Code11PropertiesChecksum;

@property (assign,nonatomic) CD_Code11PropertiesChecksum checksumProperties;
@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL stripChecksumEnabled;

/*! This method is used to enable/disable Code 11 Symbology. */
-(void)enableCode11:(BOOL)enabled;
/*! This method is used to enable/disable Strip Checksum setting. */
-(void)enableStripChecksum:(BOOL)stripChecksumEnabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_Code11PropertiesChecksum)checksumProperties;
/*! This method is used to retrieve if Code 11 is enable/disable. */
-(BOOL)getCode11Setting;
/*! This method is used to retrieve Strip Checksum setting. */
-(BOOL)getStripChecksumSetting;
/*! This method is used to retrieve Checksum setting. */
-(CD_Code11PropertiesChecksum)getChecksumSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Code32 symbology.
 */
@interface CD_Code32Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Code 32 Symbology. */
-(void)enableCode32:(BOOL)enabled;
/*! This method is used to retrieve if Code 32 is enable/disable. */
-(BOOL)getCode32Setting;

@end
//#################################################

//#################################################
/*!
 Properties for the Plessy symbology.
 */
@interface CD_PlesseyProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Plessey Symbology. */
-(void)enablePlessey:(BOOL)enabled;
/*! This method is used to retrieve if Plessey is enable/disable. */
-(BOOL)getPlesseySetting;

@end
//#################################################

//#################################################

/*!
 Properties for the MSI Plessey symbology.
 */
@interface CD_MSIPlesseyProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_MSIPlesseyPropertiesChecksum
 
 @brief Represents information about MSI Plessey  checksum supported by CortexDecoder.
 */
typedef enum {
    CD_MSIPlesseyPropertiesChecksum_Disabled,
    CD_MSIPlesseyPropertiesChecksum_EnabledMod10,
    CD_MSIPlesseyPropertiesChecksum_EnabledMod10_10,
    CD_MSIPlesseyPropertiesChecksum_EnabledMod11_10,
} CD_MSIPlesseyPropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_MSIPlesseyPropertiesChecksum checksumProperties;
@property (assign,nonatomic) BOOL stripChecksumEnabled;
@property (assign,nonatomic) int minimumLength;

/*! This method is used to enable/disable MSI Plessey Symbology. */
-(void)enableMSIPlessey:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_MSIPlesseyPropertiesChecksum)checksumProperties;
/*! This method is used to enable/disable Strip Check Digit setting. */
-(void)enableStripChecksum:(BOOL)stripChecksumEnabled;
/*!
 @brief This method is used to set minimum length for barcode to be decoded.
 
 @remarks Defaults to 1.
 */
-(void)changeMinimumLength:(int)minimumLength;
/*! This method is used to retrieve if MSI Plessey is enable/disable. */
-(BOOL)getMSIPlesseySetting;
/*! This method is used to retrieve Checksum setting. */
-(CD_MSIPlesseyPropertiesChecksum)getChecksumSetting;
/*! This method is used to retrieve Strip Checksum setting. */
-(BOOL)getStripChecksumSetting;
/*! This method is used to retrieve Minimum Length value for MSI Plessey. */
-(int)getMinimumLengthSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Telepen symbology.
 */
@interface CD_TelepenProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Telepen Symbology. */
-(void)enableTelepen:(BOOL)enabled;
/*! This method is used to retrieve if Telepen is enable/disable. */
-(BOOL)getTelepenSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Trioptic symbology.
 */
@interface CD_TriopticProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL stripStartStopCharactersEnabled;

/*! This method is used to enable/disable Trioptic Symbology. */
-(void)enableTrioptic:(BOOL)enabled;
/*! This method is used to enable/disable Strip Start Stop Character setting. */
-(void)enableStripStartStopCharacters:(BOOL)stripStartStopCharactersEnabled;
/*! This method is used to retrieve if Trioptic is enable/disable. */
-(BOOL)getTriopticSetting;
/*! This method is used to retrieve Strip Start Stop Character setting. */
-(BOOL)getStripStartStopCharactersSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Matrix 2 of 5 symbology.
 */
@interface CD_Matrix2of5Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_Matrix2of5PropertiesChecksum
 
 @brief Represents information about Matrix 2 of 5  checksum supported by CortexDecoder.
 */
typedef enum {
    CD_Matrix2of5PropertiesChecksum_Disabled,
    CD_Matrix2of5PropertiesChecksum_Enabled,
    CD_Matrix2of5PropertiesChecksum_EnabledStripCheckCharacter,
} CD_Matrix2of5PropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_Matrix2of5PropertiesChecksum checksumProperties;

/*! This method is used to enable/disable Matrix 2 Of 5 Symbology. */
-(void)enableMatrix2Of5:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_Matrix2of5PropertiesChecksum)checksumProperties;
/*! This method is used to retrieve if Matrix 2 Of 5 is enable/disable. */
-(BOOL)getMatrix2Of5Setting;
/*! This method is used to retrieve Checksum setting. */
-(CD_Matrix2of5PropertiesChecksum)getChecksumSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Straight 2 of 5 symbology.
 */
@interface CD_Straight2of5Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_Straight2of5PropertiesChecksum
 
 @brief Represents information about Straight 2 of 5  checksum supported by CortexDecoder.
 */
typedef enum {
    CD_Straight2of5PropertiesChecksum_Disabled,
    CD_Straight2of5PropertiesChecksum_Enabled,
    CD_Straight2of5PropertiesChecksum_EnabledStripCheckCharacter,
} CD_Straight2of5PropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_Straight2of5PropertiesChecksum checksumProperties;

/*! This method is used to enable/disable Straight 2 Of 5 Symbology. */
-(void)enableStraight2Of5:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_Straight2of5PropertiesChecksum)checksumProperties;
/*! This method is used to retrieve if Straight 2 Of 5 is enable/disable. */
-(BOOL)getStraight2Of5Settings;
/*! This method is used to retrieve Checksum setting. */
-(CD_Straight2of5PropertiesChecksum)getChecksumSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Hong Kong 2 of 5 symbology.
 */
@interface CD_HongKong2of5Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_HongKong2of5PropertiesChecksum
 
 @brief Represents information about HongKong 2 of 5 checksum supported by CortexDecoder.
 */
typedef enum {
    CD_HongKong2of5PropertiesChecksum_Disabled,
    CD_HongKong2of5PropertiesChecksum_Enabled,
    CD_HongKong2of5PropertiesChecksum_EnabledStripCheckCharacter,
} CD_HongKong2of5PropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_HongKong2of5PropertiesChecksum checksumProperties;

/*! This method is used to enable/disable HongKong 2 Of 5 Symbology. */
-(void)enableHongKong2Of5:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_HongKong2of5PropertiesChecksum)checksumProperties;
/*! This method is used to retrieve if HongKong 2 Of 5 is enable/disable. */
-(BOOL)getHongKong2Of5Setting;
/*! This method is used to retrieve Checksum setting. */
-(CD_HongKong2of5PropertiesChecksum)getChecksumSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the NEC 2 of 5 symbology.
 */
@interface CD_NEC2of5Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_NEC2of5PropertiesChecksum
 
 @brief Represents information about NEC 2 of 5  checksum supported by CortexDecoder.
 */
typedef enum {
    CD_NEC2of5PropertiesChecksum_Disabled,
    CD_NEC2of5PropertiesChecksum_Enabled,
    CD_NEC2of5PropertiesChecksum_EnabledStripCheckCharacter,
} CD_NEC2of5PropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_NEC2of5PropertiesChecksum checksumProperties;

/*! This method is used to enable/disable NEC 2 Of 5 Symbology. */
-(void)enableNEC2Of5:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_NEC2of5PropertiesChecksum)checksumProperties;
/*! This method is used to retrieve if NEC 2 Of 5 is enable/disable. */
-(BOOL)getNEC2Of5Setting;
/*! This method is used to retrieve Checksum setting. */
-(CD_NEC2of5PropertiesChecksum)getChecksumSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the IATA 2 of 5 symbology.
 */
@interface CD_IATA2of5Properties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_IATA2of5PropertiesChecksum
 
 @brief Represents information about IATA 2 of 5  checksum supported by CortexDecoder.
 */
typedef enum {
    CD_IATA2of5PropertiesChecksum_Disabled,
    CD_IATA2of5PropertiesChecksum_Enabled,
    CD_IATA2of5PropertiesChecksum_EnabledStripCheckCharacter,
} CD_IATA2of5PropertiesChecksum;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_IATA2of5PropertiesChecksum checksumProperties;
@property (assign,nonatomic) int minimumLength;

/*! This method is used to enable/disable IATA 2 Of 5 Symbology. */
-(void)enableIATA2Of5:(BOOL)enabled;
/*! This method is used to change Checksum setting. */
-(void)changeChecksumProperties:(CD_IATA2of5PropertiesChecksum)checksumProperties;
/*!This method is used to set minimum length for barcode to be decoded.
 
 @remarks Defaults to 1.
 */
-(void)changeMinimumLength:(int)minimumLength;
/*! This method is used to retrieve if IATA 2 Of 5 is enable/disable. */
-(BOOL)getIata2Of5Setting;
/*! This method is used to retrieve Checksum setting. */
-(CD_IATA2of5PropertiesChecksum)getChecksumSetting;
/*! This method is used to retrieve Minimum Length value for IATA 2 Of 5. */
-(int)getMinimumLengthSetting;

@end
//#################################################

//#################################################
@interface CD_PharmacodeProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) int minimumBars;
@property (assign,nonatomic) int maximumBars;
@property (assign,nonatomic) int minimumValue;
@property (assign,nonatomic) int maximumValue;

/*! This method is used to enable/disable Pharmacode Symbology. */
-(void)enablePharmacode:(BOOL)enabled;
/*! This method is used to enable/disable Minimum Bars setting. */
-(void)changeMinimumBars:(int)minimumBars;
/*! This method is used to enable/disable Minimum Value setting. */
-(void)changeMinimumValue:(int)minimumValue;
/*! This method is used to enable/disable Maximum Bars setting. */
-(void)changeMaximumBars:(int)maximumBars;
/*! This method is used to enable/disable Maximum Value setting. */
-(void)changeMaximumValue:(int)maximumValue;
/*! This method is used to retrieve if Pharmacode is enable/disable. */
-(BOOL)getPharmacodeSetting;
/*! This method is used to retrieve Minimum Bars setting. */
-(int)getMinimumBarsSetting;
/*! This method is used to retrieve Minimum Value setting. */
-(int)getMinimumValueSetting;
/*! This method is used to retrieve Maximum Bars setting. */
-(int)getMaximumBarsSetting;
/*! This method is used to retrieve Maximum Value setting. */
-(int)getMaximumValueSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the PDF 417 symbology.
 */
@interface CD_PDF417Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable PDF 417 Symbology. */
-(void)enablePDF417:(BOOL)enabled;
/*! This method is used to retrieve if PDF 417 is enable/disable. */
-(BOOL)getPDF417Setting;

@end
//#################################################

//#################################################
/*!
 Properties for the Micro PDF417 symbology.
 */
@interface CD_MicroPDF417Properties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Micro PDF 417 Symbology. */
-(void)enableMicroPDF417:(BOOL)enabled;
/*! This method is used to retrieve if Micro PDF 417 is enable/disable. */
-(BOOL)getMicroPDF417Setting;

@end
//#################################################

//#################################################
/*!
 Properties for the Codablock F symbology.
 */
@interface CD_CodablockFProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Codablock Symbology.
 
 @remarks Code128 needs to be enabled to decode CodablockF.
 */
-(void)enableCodablock:(BOOL)enabled;
/*! This method is used to retrieve if Codablock is enable/disable. */
-(BOOL)getCodablockSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the QR symbology.
 */
@interface CD_QRProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_QRPropertiesPolarity
 
 @brief Represents information about QR polarity supported by CortexDecoder.
 */
typedef enum {
    CD_QRPropertiesPolarity_DarkOnLight = 1,
    CD_QRPropertiesPolarity_LightOnDark = -1,
    CD_QRPropertiesPolarity_Either = 0,
} CD_QRPropertiesPolarity;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) BOOL model1DecodingEnabled;
@property (assign,nonatomic) CD_QRPropertiesPolarity polarity;
@property (assign,nonatomic) BOOL mirrorDecodingEnabled;

/*! This method is used to enable/disable QR Symbology. */
-(void)enableQR:(BOOL)enabled;
/*! This method is used to enable/disable Model 1 Decoding setting. */
-(void)enableModel1Decoding:(BOOL)model1DecodingEnabled;
/*! This method is used to change Polarity setting. */
-(void)changePolarity:(CD_QRPropertiesPolarity)polarity;
/*! This method is used to enable/disable Mirror Decoding setting. */
-(void)enableMirrorDecoding:(BOOL)mirrorDecodingEnabled;
/*! This method is used to retrieve if QR is enable/disable. */
-(BOOL)getQRSetting;
/*! This method is used to retrieve Model 1 Decoding setting. */
-(BOOL)getModel1DecodingSetting;
/*! This method is used to retrieve Polarity setting. */
-(CD_QRPropertiesPolarity)getPolaritySetting;
/*! This method is used to retrieve Mirror Decoding setting. */
-(BOOL)getMirrorDecodingSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Micro QR symbology.
 */
@interface CD_MicroQRProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Micro QR Symbology. */
-(void)enableMicroQR:(BOOL)enabled;
/*! This method is used to retrieve if Micro QR is enable/disable. */
-(BOOL)getMicroQRSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Data Matrix symbology.
 */
@interface CD_DataMatrixProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_DataMatrixPropertiesPolarity
 
 @brief Represents information about Data Matrix polarity supported by CortexDecoder.
 */
typedef enum {
    CD_DataMatrixPropertiesPolarity_DarkOnLight = 1,
    CD_DataMatrixPropertiesPolarity_LightOnDark = -1,
    CD_DataMatrixPropertiesPolarity_Either = 0,
} CD_DataMatrixPropertiesPolarity;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_DataMatrixPropertiesPolarity polarity;
@property (assign,nonatomic) BOOL mirrorDecodingEnabled;
@property (assign,nonatomic) BOOL rectangularDecodingEnabled;

/*! This method is used to enable/disable DataMatrix Symbology. */
-(void)enableDataMatrix:(BOOL)enabled;
/*! This method is used to change Polarity setting. */
-(void)changePolarity:(CD_DataMatrixPropertiesPolarity)polarity;
/*! This method is used to enable/disable Mirror Decoding setting. */
-(void)enableMirrorDecoding:(BOOL)mirrorDecodingEnabled;
/*! This method is used to enable/disable Rectangular Decoding setting. */
-(void)enableRectangularDecoding:(BOOL)rectangularDecodingEnabled;
/*! This method is used to retrieve if DataMatrix is enable/disable. */
-(BOOL)getDataMatrixSetting;
/*! This method is used to retrieve Polarity setting. */
-(CD_DataMatrixPropertiesPolarity)getPolaritySetting;
/*! This method is used to retrieve Mirror Decoding setting. */
-(BOOL)getMirrorDecodingSetting;
/*! This method is used to retrieve Rectangular Decoding setting. */
-(BOOL)getRectangularDecodingSetting;

@end
//#################################################

//#################################################

/*!
 @brief Properties for the DotCode symbology.
 
 @since version 3.4
 */
@interface CD_DotCodeProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_DotCodePropertiesPolarity
 
 @brief Represents information about DotCode polarity supported by CortexDecoder.
 */
typedef enum{
    CD_DotCodePropertiesPolarity_DarkOnLight = 1,
    CD_DotCodePropertiesPolarity_LightOnDark = -1,
    CD_DotCodePropertiesPolarity_Either = 0,
}CD_DotCodePropertiesPolarity;

/*! This method is used to enable/disable DotCode Symbology. */
-(void)enableDotCode:(BOOL)enabled;
/*! This method is used to change Polarity setting. */
-(void)changePolarity:(CD_DotCodePropertiesPolarity)polarity;
/*! This method is used to enable/disable Mirror Decoding setting. */
-(void)enableMirrorDecoding:(BOOL)mirrorDecodingEnabled;
/*! This method is used to retrieve if DotCode is enable/disable. */
-(BOOL)getDotCodeSetting;
/*! This method is used to retrieve Polarity setting. */
-(CD_DotCodePropertiesPolarity)getPolaritySetting;
/*! This method is used to retrieve Mirror Decoding setting. */
-(BOOL)getMirrorDecodingSetting;

@end

//#################################################

//#################################################

/*!
 Properties for the Aztec symbology.
 */
@interface CD_AztecProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_AztecPropertiesPolarity
 
 @brief Represents information about Aztec polarity supported by CortexDecoder.
 */
typedef enum {
    CD_AztecPropertiesPolarity_DarkOnLight = 1,
    CD_AztecPropertiesPolarity_LightOnDark = -1,
    CD_AztecPropertiesPolarity_Either = 0,
} CD_AztecPropertiesPolarity;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_AztecPropertiesPolarity polarity;
@property (assign,nonatomic) BOOL mirrorDecodingEnabled;

/*! This method is used to enable/disable Aztec Symbology. */
-(void)enableAztec:(BOOL)enabled;
/*! This method is used to change Polarity setting. */
-(void)changePolarity:(CD_AztecPropertiesPolarity)polarity;
/*! This method is used to enable/disable Mirror Decoding setting. */
-(void)enableMirrorDecoding:(BOOL)mirrorDecodingEnabled;
/*! This method is used to retrieve if Aztec is enable/disable. */
-(BOOL)getAztecSetting;
/*! This method is used to retrieve Polarity setting. */
-(CD_AztecPropertiesPolarity)getPolaritySetting;
/*! This method is used to retrieve Mirror Decoding setting. */
-(BOOL)getMirrorDecodingSetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Grid Matrix symbology.
 */
@interface CD_GridMatrixProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_GridMatrixPropertiesPolarity
 
 @brief Represents information about Grid Matrix polarity supported by CortexDecoder.
 */
typedef enum {
    CD_GridMatrixPropertiesPolarity_DarkOnLight = 1,
    CD_GridMatrixPropertiesPolarity_LightOnDark = -1,
    CD_GridMatrixPropertiesPolarity_Either = 0,
} CD_GridMatrixPropertiesPolarity;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_GridMatrixPropertiesPolarity polarity;
@property (assign,nonatomic) BOOL mirrorDecodingEnabled;

/*! This method is used to enable/disable GridMatrix Symbology. */
-(void)enableGridMatrix:(BOOL)enabled;
/*! This method is used to enable/disable Mirror Decoding setting. */
-(void)enableMirrorDecoding:(BOOL)mirrorDecodingEnabled;
/*! This method is used to change Polarity setting. */
-(void)changePolarity:(CD_GridMatrixPropertiesPolarity)polarity;
/*! This method is used to retrieve if GridMatrix is enable/disable. */
-(BOOL)getGridMatrixSetting;
/*! This method is used to retrieve Mirror Decoding setting. */
-(BOOL)getMirrorDecodingSettings;
/*! This method is used to retrieve Polarity setting. */
-(CD_GridMatrixPropertiesPolarity)getPolaritySetting;

@end
//#################################################

//#################################################

/*!
 Properties for the Go Code symbology.
 */
@interface CD_GoCodeProperties : NSObject <CD_SymbologyProperties>

/*!
 @enum CD_GoCodePropertiesPolarity
 
 @brief Represents information about Go Code polarity supported by CortexDecoder.
 
 @remarks Not yet supported
 */
typedef enum {
    CD_GoCodePropertiesPolarity_DarkOnLight = 1,
    CD_GoCodePropertiesPolarity_LightOnDark = -1,
    CD_GoCodePropertiesPolarity_Either = 0,
} CD_GoCodePropertiesPolarity;

@property (assign,nonatomic) BOOL enabled;
@property (assign,nonatomic) CD_GoCodePropertiesPolarity polarity;

/*! This method is used to enable/disable Go Code Symbology. */
-(void)enableGoCode:(BOOL)enabled;
/*! This method is used to change Polarity setting. */
-(void)changePolarity:(CD_GoCodePropertiesPolarity)polarity;
/*! This method is used to retrieve if Go Code is enable/disable. */
-(BOOL)getGoCodeSetting;
/*! This method is used to retrieve Polarity setting. */
-(CD_GoCodePropertiesPolarity)getPolaritySetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Han Xin Code symbology.
 */
@interface CD_HanXinCodeProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable HanXin Code Symbology. */
-(void)enableHanXinCode:(BOOL)enabled;
/*! This method is used to retrieve if HanXin Code is enable/disable. */
-(BOOL)getHanXinCodeSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Maxi Code symbology.
 */
@interface CD_MaxiCodeProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Maxi Code Symbology. */
-(void)enableMaxiCode:(BOOL)enabled;
/*! This method is used to retrieve if Maxi Code is enable/disable. */
-(BOOL)getMaxiCodeSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the USPS Postnet symbology.
 */
@interface CD_USPSPostnetProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable USPS Postnet Symbology. */
-(void)enableUSPSPostnet:(BOOL)enabled;
/*! This method is used to retrieve if USPS Postnet is enable/disable. */
-(BOOL)getUSPSPostnetSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the USPS Planet symbology.
 */
@interface CD_USPSPlanetProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable USPS Planet Symbology. */
-(void)enableUSPSPlanet:(BOOL)enabled;
/*! This method is used to retrieve if USPS Planet is enable/disable. */
-(BOOL)getUSPSPlanetSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the USPS Intelligent Mail symbology.
 */
@interface CD_USPSIntelligentMailProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable USPS Intelligent Mail Symbology. */
-(void)enableUSPSIntelligentMail:(BOOL)enabled;
/*! This method is used to retrieve if USPS Intelligent Mail is enable/disable. */
-(BOOL)getUSPSIntelligentMailSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Australia Post symbology.
 */
@interface CD_AustraliaPostProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Australia Post Symbology. */
-(void)enableAustraliaPost:(BOOL)enable;
/*! This method is used to retrieve if Australia Post is enable/disable. */
-(BOOL)getAustraliaPostSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Canada Post symbology.
 */
@interface CD_CanadaPostProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Canada Post Symbology. */
-(void)enableCanadaPost:(BOOL)enabled;
/*! This method is used to retrieve if Canada Post is enable/disable. */
-(BOOL)getCanadaPostSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Dutch Post symbology.
 */
@interface CD_DutchPostProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Dutch Post Symbology. */
-(void)enableDutchPost:(BOOL)enabled;
/*! This method is used to retrieve if Dutch Post is enable/disable. */
-(BOOL)getDutchPostSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Japan Post symbology.
 */
@interface CD_JapanPostProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Japan Post Symbology. */
-(void)enableJapanPost:(BOOL)enabled;
/*! This method is used to retrieve if Japan Post is enable/disable. */
-(BOOL)getJapanPostSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Royal Mail symbology.
 */
@interface CD_RoyalMailProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Royal Mail Symbology. */
-(void)enableRoyalMail:(BOOL)enabled;
/*! This method is used to retrieve if Royal Mail is enable/disable. */
-(BOOL)getRoyalMailSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the Korea Post symbology.
 */
@interface CD_KoreaPostProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable Korea Post Symbology. */
-(void)enableKoreaPost:(BOOL)enabled;
/*! This method is used to retrieve if Korea Post is enable/disable. */
-(BOOL)getKoreaPostSetting;

@end
//#################################################

//#################################################
/*!
 Properties for the UPU symbology.
 */
@interface CD_UPUProperties : NSObject <CD_SymbologyProperties>

@property (assign,nonatomic) BOOL enabled;

/*! This method is used to enable/disable UPU Symbology. */
-(void)enableUPU:(BOOL)enabled;
/*! This method is used to retrieve if UPU is enable/disable. */
-(BOOL)getUPUSetting;

@end
//#################################################

/*!
 @typedef BarcodeBounds
 
 @brief A structure that indicates the 4 points of a decoded barcode
 */
typedef struct BarcodeBounds {
    CGPoint points[4];
} BarcodeBounds;

#pragma mark - CortexDecoderLibraryDelegate -
/*!
 @protocol CortexDecoderLibraryDelegate
 
 @brief This is the protocol for handeling Cortex Decoder callbacks.
 */
@protocol CortexDecoderLibraryDelegate<NSObject>

/*!
 @brief Protocol method that is called when the decoder has successfully decoded barcode(s).
 
 @param data NSArray that contains NSData objects.
 
 @param type NSArray that contains CD_SymbologyType objects.
 
 @see CD_SymbologyType
 */
-(void)receivedMultiDecodedData:(NSArray*)data andType:(NSArray *)type;

/*!
 @enum CD_SymbologyType
 
 @brief This is the type define for all of the supported symbologies.
 
 @see receivedDecodedData:andType:
 */

typedef enum{
    CD_SymbologyType_Undefined,
    CD_SymbologyType_GC,
    CD_SymbologyType_DataMatrix,
    CD_SymbologyType_QR,
    CD_SymbologyType_Aztec,
    CD_SymbologyType_MC,
    CD_SymbologyType_PDF417,
    CD_SymbologyType_MPDF,
    CD_SymbologyType_Code39,
    CD_SymbologyType_Interleaved2of5,
    CD_SymbologyType_Codabar,
    CD_SymbologyType_Code128,
    CD_SymbologyType_Code93,
    CD_SymbologyType_UPCA,
    CD_SymbologyType_UPCE,
    CD_SymbologyType_EAN13,
    CD_SymbologyType_EAN8,
    CD_SymbologyType_DB14,
    CD_SymbologyType_CCA,
    CD_SymbologyType_CCB,
    CD_SymbologyType_CCC,
    CD_SymbologyType_DataBarStacked,
    CD_SymbologyType_DataBarLimited,
    CD_SymbologyType_DataBarExpanded,
    CD_SymbologyType_DataBarExpandedStacked,
    CD_SymbologyType_HanXin,
    CD_SymbologyType_QRMicro,
    CD_SymbologyType_QRModel1,
    CD_SymbologyType_CustomNC,
    CD_SymbologyType_Extended,
    CD_SymbologyType_Code11,
    CD_SymbologyType_Code32,
    CD_SymbologyType_Plessy,
    CD_SymbologyType_MSIPlessy,
    CD_SymbologyType_Telepen,
    CD_SymbologyType_Trioptic,
    CD_SymbologyType_Pharmacode,
    CD_SymbologyType_Matrix2of5,
    CD_SymbologyType_Straight2of5,
    CD_SymbologyType_Code49,
    CD_SymbologyType_Codr16k,
    CD_SymbologyType_CodablockF,
    CD_SymbologyType_USPSPostnet,
    CD_SymbologyType_USPSPlanet,
    CD_SymbologyType_USPSIntelligentMail,
    CD_SymbologyType_AustraliaPost,
    CD_SymbologyType_DutchPost,
    CD_SymbologyType_JapanMail,
    CD_SymbologyType_RoyalMail,
    CD_SymbologyType_UPU,
    CD_SymbologyType_KoreaPost,
    CD_SymbologyType_HongKong2of5,
    CD_SymbologyType_NEC2of5,
    CD_SymbologyType_IATA2of5,
    CD_SymbologyType_CanadaPost,
    CD_SymbologyType_Pro1,
    CD_SymbologyType_DataBarStacked_CCA,
    CD_SymbologyType_DataBarStacked_CCB,
    CD_SymbologyType_DataBarStacked_CCC,
    CD_SymbologyType_DataBarLimited_CCA,
    CD_SymbologyType_DataBarLimited_CCB,
    CD_SymbologyType_DataBarLimited_CCC,
    CD_SymbologyType_DataBarExpanded_CCA,
    CD_SymbologyType_DataBarExpanded_CCB,
    CD_SymbologyType_DataBarExpanded_CCC,
    CD_SymbologyType_DataBarExpandedStacked_CCA,
    CD_SymbologyType_DataBarExpandedStacked_CCB,
    CD_SymbologyType_DataBarExpandedStacked_CCC,
    CD_SymbologyType_BC412,
    CD_SymbologyType_GridMatrix,
    CD_SymbologyType_Code128_CCA,
    CD_SymbologyType_Code128_CCB,
    CD_SymbologyType_Code128_CCC,
    CD_SymbologyType_UPCA_CCA,
    CD_SymbologyType_UPCA_CCB,
    CD_SymbologyType_UPCA_CCC,
    CD_SymbologyType_UPCE_CCA,
    CD_SymbologyType_UPCE_CCB,
    CD_SymbologyType_UPCE_CCC,
    CD_SymbologyType_EAN8_CCA,
    CD_SymbologyType_EAN8_CCB,
    CD_SymbologyType_EAN8_CCC,
    CD_SymbologyType_EAN13_CCA,
    CD_SymbologyType_EAN13_CCB,
    CD_SymbologyType_EAN13_CCC,
    CD_SymbologyType_DB_14_CCA,
    CD_SymbologyType_DB_14_CCB,
    CD_SymbologyType_DB_14_CCC,
    CD_SymbologyType_TLC39,
    CD_SymbologyType_DotCode
} CD_SymbologyType;

/*!
 @brief Protocol method that is called when the decoder has successfully decoded a barcode.

 @param data The data that the decoder has read.

 @param type The symbology type of the barcode that was read.
 
 @see CD_SymbologyType
 */
-(void)receivedDecodedData:(NSData*)data andType:(CD_SymbologyType)type;

/*!
 @brief Protocol method used to activate Enterprise CortexDecoderLibrary license (EDK).
 
 @discussion Protocol method that is called when the decoder needs Configuration Key (EDK Key) and Customer ID.
                When both data, that is, Configuration Key (EDK Key) and Customer ID are valid decoder will activate configuration Key (EDK Key) License.
 
 @param requestedData NSString that will either be NSString "configurationKey" (EDK Key) or "customerID".
        When NSString is equal to configurationKey (EDK Key) decoder is expecting configuration Key Data to be returned.
        When NSString is equal to customerID decoder is expecting customer ID to be returned.
 
 @return NSString This is either a Configuration Key (EDK Key) and Customer ID that is returned to CortexDecoder for license activation.
 
 @see receivedConfigFileActivationResult:
 @see receivedConfigFileError:
 */
@optional
-(NSString*)configurationKeyData:(NSString*)requestedData;

/*!
 @brief Protocol method used to inform if Enterprise license (EDK) activation was successful or not.
 
 @discussion Protocol method is called when the decoder either activates/deactivates configuration Key License (EDK license).
 
 @param licenseActivated  Contains BOOL value indicating if configuration Key License is activated/deactivated.
        YES means configuration Key License is actived.
        NO means configuration Key License is deactivated.
 
 @see configurationKeyData:
 */
@optional
-(void)receivedConfigFileActivationResult:(BOOL)licenseActivated;

/*!
 @brief Protocol method which shares detailed error message when Enterprise license (EDK) activation was not successful.
 
 @discussion Protocol method is called when an error is occured while trying to activate configuration Key License (EDK License).
 
 @param error NSString that contains NSString explaining what error is occured.
 
 @see configurationKeyData:
 */
@optional
-(void)receivedConfigFileError:(NSString*)error;

/*!
 @enum CD_License_Activation_Result
 
 @brief Describes different states for license activation results.
 
 @discussion Provides different license activation states that might occur when an attempt to activate a license is made.
 
 @field License_Activated               Indicates license is activated.
 
 @field License_Valid                   Indicates license is valid when validateLicenseKey is called.
 
 @field License_Expired                 Indicates license is expired.
 
 @field License_Invalid                 Indicates license is invalid.
 
 @field License_Not_Found               Indicates no license was found on device.
 
 @field License_Mismatch                Indicates license key is invalid.
 
 @field License_Count_Exceeded          Indicates all available license for key is used up.
 
 @field Network_Not_Available           Indicates network is not available on device.
 
 @field License_Server_Not_Available    Indicates device is not able to connected with server at the moment.
 
 @field License_Expires_In_Days         Indicates that license will expire in x days. Days can be calculated after subtracting 100 from the value.
 
 @see receivedLicenseActivationResult:withMessage:
 @see CortexDecoderLibrary::activateLicenseKey:
 @see CortexDecoderLibrary::validateLicenseKey
 */
typedef enum{
    License_Activated,
    License_Valid,
    License_Expired,
    License_Invalid,
    License_Not_Found,
    License_Mismatch,
    License_Count_Exceeded,
    Network_Not_Available,
    License_Server_Not_Available,
    License_Expires_In_Days = 100
} CD_License_Activation_Result;

/*!
 @brief Protocol method that is called when API activateLicenseKey is called in your application.
 
 @param code CD_License_Activation_Result contains a CD_License_Activation_Result enum which details about license activation result.
 
 @param message NSString that contains a brief descripition about license activation result.
 
 @remarks Do not call activateLicenseKey: API from within this callback. Application will enter an infinte loop and eventually crash.
 
 @see CD_License_Activation_Result
 @see CortexDecoderLibrary::activateLicenseKey:
 */
@optional
-(void)receivedLicenseActivationResult:(CD_License_Activation_Result)code withMessage:(NSString*)message;

/*!
 @enum CD_SledAccessoryEventType
 
 @brief Describes different code accessory events that may occur when connected.
 
 @discussion Provides information about events that might occur when Code Accessory is connected.
 
 @field Sled_AccessoryConnectedEvent                Indicates that a code sled accessory is connected to device.
 
 @field Sled_AccessoryDisconnectedEvent             Indicates that a code sled accessory is disconnected to device.
 
 @field Sled_AccessoryLeftButtonPressEvent          Indicates that left side button was press on connected code sled accessory.
 
 @field Sled_AccessoryRightButtonPressEvent         Indicates that right side button was press on connected code sled accessory.
 
 @field Sled_AccessoryLeftAndRightButtonPressEvent  Indicates that both left and right side button was press on connected code sled accessory.
 
 @field Sled_AccessoryButtonReleaseEvent            Indicates that left/right side button was released on connected code sled accessory.
 
 @see sledAccessoryEventReceived:
 */
typedef enum{
    Sled_AccessoryConnectedEvent = 0,
    Sled_AccessoryDisconnectedEvent,
    Sled_AccessoryLeftButtonPressEvent,
    Sled_AccessoryRightButtonPressEvent,
    Sled_AccessoryLeftAndRightButtonPressEvent,
    Sled_AccessoryButtonReleaseEvent
}CD_SledAccessoryEventType;

/*!
 @brief Protocol method that is called when a event occurs while using Code accessory.
 
 @param eventType The event type for Code Accessory.
 
 @remarks On Sled_AccessoryConnectedEvent/Sled_AccessoryDisconnectedEvent application should re-enable license symbologies.
            This is to ensure Symbology settings are updated once SDK changes internal licensing status when CR4300 is connected/disconnected.
 
 @see CD_SledAccessoryEventType
 
 @since version 3.0
 */
@optional
-(void)sledAccessoryEventReceived:(CD_SledAccessoryEventType)eventType;

/*!
 @brief Protocol method that is periodically called when a Code Sled is connected.
 
 @param chargingStatus NSString indicating if Code Accessory is being charged using USB, DOCK or NONE.
 
 @param batteryLevel NSString indicating batteryLevel for Code Accessory connected.
 
 @since version 3.0
 */
@optional
-(void)sledAccessoryStatusReceived:(NSString*)chargingStatus withBatteryLevel:(NSString*)batteryLevel;

/*!
 @brief Protocol method that is called every 60 seconds when API enableDecodeCountPerMin is enabled.
 
 @param decodeCount int value representing number of barcodes that were decoded in last 60 seconds.
 
 @see CortexDecoderLibrary::enableDecodeCountPerMin:
 
 @since version 3.1
 */
@optional
-(void)receivedDecodeCountPerMinData:(int)decodeCount;

/*!
 @brief Protocol method that is called to indicate how many unique barcodes have been scanned when in multi frame decode mode.
 
 @param decodeCount int value representing number of barcodes that have been scanned.
 
 @see CortexDecoderLibrary::enableMultiFrameDecoding:
 
 @since version 3.1
 */
@optional
-(void)multiFrameDecodeCount:(int)decodeCount;
@end

#pragma mark - CortexDecoderLibrary Interface -
/*!
 @brief This is the interface class for working with the Cortex Decoder Library.
                All public methods are defined within this class.
 */
@interface CortexDecoderLibrary : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

/*!
 @brief This is the delegate for the Cortex Decoder.
 
 @discussion All callbacks will be done via the delegate. The delegate should implement the
                "CortexDecoderLibraryDelegate" protocol.
 */
@property (weak,nonatomic) id<CortexDecoderLibraryDelegate> delegate;

/*!
 @brief  Used to get the shared instance of the CortexDecoderLibrary class.

 @return The singleton instance of the CortexDecoderLibrary class.
 */
+(CortexDecoderLibrary*)sharedObject;;

/*!
 @brief Used to deallocate the shared instance created for CortexDecoderLibrary class.
 
 @since version 3.3.1
 */
-(void)closeSharedObject;

/*!
 @brief This method returns a UIView which will display a live preview of
            the images the decoder is seeing. It is not required for decoder data.

 @param aRect The size of the frame that you want to get returned.

 @return A UIView with the live preview.
 */
-(UIView*)previewViewWithFrame:(CGRect)aRect;

/*!
 @brief This method sets the preview layer's video orientation.

 @param orientation Specifies the physical orientation of the device.
 */
-(void)setPreviewLayerVideoOrientation:(UIDeviceOrientation)orientation;

/*!
 @brief This method translates a CD_SymbologyType type to a NSString.

 @param type The CD_SymbologyType that you want returned as a string.

 @return A NSString representing the CD_SymbologyType passed to the method
 
 @see CortexDecoderLibraryDelegate::CD_SymbologyType
 */
+(NSString*)stringFromSymbologyType:(CD_SymbologyType)type;

/*!
 @enum CD_PerformanceType
 
 @brief Represents Performance features supported by CortexDecoder.
 
 @discussion This is the type define for all of the supported performance features.
 
 @field CD_PerformanceType_LOW_CONTRAST
 
 @field CD_PerformanceType_MULTICODE
 
 @field CD_PerformanceType_DPM
 
 @field CD_PerformanceType_PARSE_DL
 
 @field CD_PerformanceType_PARSE_GS1
 
 @field CD_PerformanceType_PARSE_UDI
 
 @see getLicensedPerformanceFeatures
 
 @since version 3.0
 */
typedef enum{
    CD_PerformanceType_Undefined,
    CD_PerformanceType_LOW_CONTRAST,
    CD_PerformanceType_MULTICODE,
    CD_PerformanceType_DPM,
    CD_PerformanceType_PARSE_DL,
    CD_PerformanceType_PARSE_GS1,
    CD_PerformanceType_PARSE_UDI
} CD_PerformanceType;

/*!
 @brief This method translates a CD_PerformanceType type to a NSString.
 
 @param type The CD_PerformanceType that you want returned as a string.
 
 @return A NSString representing the CD_PerformanceType passed to the method
 
 @see CD_PerformanceType
 
 @since version 3.0
 */
+(NSString*)stringFromPerformanceType:(CD_PerformanceType)type;

/*!
 @enum CD_VideoOutputFormat
 
 @brief Describes Video output formats supported by CortexDecoder.
 
 @discussion This is the type define for specifying video output format for the active camera.
 
 @field CD_VideoOutputFormat_8BitGrayScale  Informs CortexDecoder to capture a greyscale images for decoding. Default setting.
 
 @field CD_VideoOutput_32BGRA               Informs CortexDecoder to capture a BGRA images for decoding.
 
 @see setVideoOutputFormat:
 */
typedef enum {
    CD_VideoOutputFormat_8BitGrayScale = 1,
    CD_VideoOutputFormat_32BGRA = 2
} CD_VideoOutputFormat;

/*!
 @brief This method sets the active video output format for camera.

 @param videoOutputFormat Specifies the video output format to set for the active camera.
 
 @remarks By default CD_VideoOutputFormat_8BitGrayScale is set.
 
 @see CD_VideoOutputFormat
 */
-(void)setVideoOutputFormat:(CD_VideoOutputFormat)videoOutputFormat;


/*!
 @brief This method will start video frame capturing and pass frames to decoder for processing.
 
 @discussion If you are want finer control of video capturing, and decoding consider using API's enableVideoCapturing, enableDecoding.
 */
-(void)startDecoding;

/*!
 @brief   This method will stop video frame capturing.
 
 @discussion If you are want finer control of video capturing,
                and decoding consider using API's enableVideoCapturing, enableDecoding.
 */
-(void)stopDecoding;

/*!
 @brief This method returns the version of the Cortex Decoder.

 @return A NSString containing the decoder version.
 */
-(NSString*)decoderVersion;

/*!
 @brief This method returns the license level of the Cortex Decoder.

 @return A NSString containing the license level of the Cortex Decoder.
 */
-(NSString*)decoderVersionLevel;

/*!
 @brief This method returns the version of the Cortex Decoder Library.

 @return A NSString containing the library version.
 */
-(NSString*)libraryVersion;

/*!
 @brief This method returns the version of the Cortex Decoder SDK

 @return A NSString containing the sdk version.
 */
-(NSString*)sdkVersion;

/*!
 @brief This method enables & disables low contrast images of common 1D barcodes.
 
 @discussion Code 128, Code 39, UPC/EAN/JAN, I 2of 5, Codabar, Code 93 are
                some common 1D barcodes. With the low contrast mode enabled,
                a light on dark (i.e. inverse image) barcode can also be decoded.

 @param enabled YES to enable.
*/
-(void)lowContrastDecodingEnabled:(bool)enabled;

/*!
 @brief This method sets a timeout for how long the decoder will process a video frame.
 
 @discussion If this timeout is reached the decoder will continue processing on the next video frame if available.

 @param milliseconds This should be a positive integer representing the
        timeout in milliseconds. If set to 0 no timeout will be used.
 */
-(void)decoderTimeLimitInMilliseconds:(int)milliseconds;

/*!
 @brief This method sets the barcode decoding ROI (Region of Interest).
 
 @discussion The ROI is a rectangle specified by the position of the top-left corner point
                and the width and height. By default, the ROI is the size of the preview frame.
                It can be set to a smaller region to speed up the decoding if needed.
 
 @param roiRect This is the roi expressed as a CGRect in screen coordinates.
 @param ensure Indicates whether all 4 corners of barcode need to be inside ROI rectangle
 */
-(void)setRoiRect:(CGRect)roiRect ensureAllCorners:(BOOL)ensure;

/*!
 @brief This method sets the barcode decoding ROI (Region of Interest).
 
 @discussion This method is used to set the x coordinate for the top-left corner point of ROI.
                The ROI is a rectangle specified by the position of the top-left corner point
                and the width and height. By default, the ROI is the size of the preview frame.
                It can be set to a smaller region to speed up the decoding if needed.

 @param column This is the x or column coordinate of the ROI upper-left corner.
            The default value is 0.
 
 @see regionOfInterestTop:
 @see regionOfInterestWidth:
 @see regionOfInterestHeight:
 @see ensureRegionOfInterest:
 */
-(void)regionOfInterestLeft:(int)column;

/*!
 @brief This method sets the barcode decoding ROI (Region of Interest).
 
 @discussion This method is used to set the y coordinate for the top-left corner point of ROI.
                The ROI is a rectangle specified by the position of the top-left corner point
                and the width and height. By default, the ROI is the size of the preview frame.
                It can be set to a smaller region to speed up the decoding if needed.

 @param row This is the y or row coordinate of the ROI top-left corner.
        default value is 0.
 
 @see regionOfInterestLeft:
 @see regionOfInterestWidth:
 @see regionOfInterestHeight:
 @see ensureRegionOfInterest:
 */
-(void)regionOfInterestTop:(int)row;

/*!
 @brief This method sets the barcode decoding ROI (Region of Interest).
 
 @discussion This method is used to set the width for the ROI rectangle.
                The ROI is a rectangle specified by the position of the top-left corner point
                and the width and height. By default, the ROI is the size of the preview frame.
                It can be set to a smaller region to speed up the decoding if needed.

 @param roiWidth This is the width of the ROI rectangle. The default value is
                 0, indicating the full image width is used. Otherwise, roiWidth can be a
                 value up to (imageWidth – roiWidth).
 
 @see regionOfInterestLeft:
 @see regionOfInterestTop:
 @see regionOfInterestHeight:
 @see ensureRegionOfInterest:
 */
-(void)regionOfInterestWidth:(int)roiWidth;

/*!
 @brief This method sets barcode decoding ROI (Region of Interest).
 
 @discussion This method is used to set the height for the ROI rectangle.
                The ROI is a rectangle specified by the position of the top-left corner point
                and the width and height. By default, the ROI is the size of the preview frame.
                It can be set to a smaller region to speed up the decoding if needed.

 @param roiHeight This is the height of the ROI rectangle. The default value is
                     0, indicating the full image height is used. Otherwise, roiHeight can be a
                     value up to (imageHeight – roiHeight).
 
 @see regionOfInterestLeft:
 @see regionOfInterestTop:
 @see regionOfInterestWidth:
 @see ensureRegionOfInterest:
 */
-(void)regionOfInterestHeight:(int)roiHeight;

/*!
 @brief This method enables & disables strict region of interest decoding.
 
 @discussion When the barcode decoding ROI is set to be a smaller region inside the image, the
                barcode algorithm will search for barcodes with the ROI. As long as a
                sufficient portion of the barcode is in the ROI, the barcode will be found
                and decoded. Use the following to ensure that a barcode will not be decoded
                unless its entire area is inside the ROI.

 @param enable YES to enable.
 
 @see regionOfInterestLeft:
 @see regionOfInterestTop:
 @see regionOfInterestWidth:
 @see regionOfInterestHeight:
 */
-(void)ensureRegionOfInterest:(BOOL)enable;

/*!
 @brief This method enables & disables vibrate notification after a successful scan.

 @param enable YES to enable. Default value is disabled.
 */
-(void)enableVibrateOnScan:(BOOL)enable;

/*!
 @brief This method enable & disables robust mode which helps decode most difficult barcodes.
 
 @param enable YES to enable. Default value is disabled.
 
 @since version 3.4
 */
-(void)enableRobustMode:(BOOL)enable;

/*!
 @enum CD_CameraType
 
 @brief Differrent Camera types supported by CortexDecoder.
 
 @discussion This is the type defines for specifying which camera to use.
 
 @field CD_CameraType_BackFacing Specifies the back-facing camera. Default setting.
 
 @field CD_CameraType_FrontFacing Specifies the front-facing camera.
 
 @see setCameraType:
 */
typedef enum {
    CD_CameraType_BackFacing,
    CD_CameraType_FrontFacing
} CD_CameraType;

/*!
 @brief This method informs CortexDecoder which camera to be used for capturing frames.
 
 @param cameraType Specifies camera type to be used for capturing frames for decoding.
 
 @remarks By default Back facing camera is used.
 
 @see CD_CameraType
 */
-(void)setCameraType:(CD_CameraType)cameraType;

/*!
 @enum CD_Focus
 
 @brief Differrent Focus modes supported by CortexDecoder.
 
 @discussion This is the type define for controlling focus.
 
 @field CD_Focus_Normal Default for iOS 7. Variable focus mid to close range.
 
 @field CD_Focus_Far Variable focus far range.
 
 @field CD_Focus_Fix_Normal Only available for iOS 8 and above. Fixed focus mid range. Defaults to CD_Focus_Normal in iOS 7 and below environments.
 
 @field CD_Focus_Fix_Far Only available for iOS 8 and above. Fixed focus far range. Defaults to CD_Focus_Far in iOS 7 and below environments.
 
 @field CD_Focus_Smooth_Auto Device will automatically focus whenever needed.
 
 @remarks By default if supported by device CD_Focus_Smooth_Auto is used.
 
 @see isFocusModeSupported:
 @see setFocus:
 */
typedef enum {
    CD_Focus_Normal,
    CD_Focus_Far,
    CD_Focus_Fix_Normal,
    CD_Focus_Fix_Far,
    CD_Focus_Smooth_Auto
} CD_Focus;

/*!
 @brief This method sets the active focus mode.

 @param focus Specifies the focus mode to set for the active camera.
 
 @remarks By default if supported by device CD_Focus_Smooth_Auto is used.
 
 @see CD_Focus
 */
-(void)setFocus:(CD_Focus)focus;

/*!
 @brief This method allows to set custom lens position for Near Fixed Focus.
 
 @param lensPosition Lens Position value is set for Near Fixed Focus mode. The value can be between 0 and 1.
 
 @since version 3.1
 */
-(void)setNearFixedFocus:(CGFloat)lensPosition;

/*!
 @brief This method allows to set custom lens position for Far Fixed Focus.
 
 @param lensPosition Lens Position value is set for Far Fixed Focus mode. The value can be between 0 and 1.
 
 @since version 3.1
 */
-(void)setFarFixedFocus:(CGFloat)lensPosition;

/*!
 @brief This method queries the active camera to see if it supports the specified focus mode.

 @param focus Determines if the the focus mode is supported by the active camera.  See CD_Focus for enumeration types.
 
 @see CD_Focus
 */
-(BOOL)isFocusModeSupported:(CD_Focus)focus;

/*!
 @enum CD_Torch
 
 @brief Different Torch modes supported by CortexDecoder.
 
 @discussion This is the type define for controlling the torch.
 
 @field CD_Torch_On Torch always on.
 
 @field CD_Torch_Off Torch always off.
 
 @field CD_Torch_Auto The torch is controled by iOS based on available light.
 
 @remarks Default mode is CD_Torch_Auto
 
 @see setTorch:
 */
typedef enum {
    CD_Torch_On,
    CD_Torch_Off,
    CD_Torch_Auto
} CD_Torch;

/*!
 @brief This method sets the active torch mode.

 @param torchMode Mode of the torch to be used.
 
 @remarks Default mode is CD_Torch_Auto
 
 @see CD_Torch
 @see setTorchBrightness:
 @see applyTorchSettings
 */
-(void)setTorch:(CD_Torch)torchMode;

/*!
 @brief This method sets the brightness of the torch.

 @param brightness Value that ranges from .01 to 1.
 
 @remarks Default value is 0.5
 
 @see CD_Torch
 @see setTorch:
 @see applyTorchSettings
 
 */
- (void)setTorchBrightness:(CGFloat)brightness;

/*!
 @brief This method forces torch settings to be applied that were previously set by setTorch: API
 
 @see CD_Torch
 @see setTorch:
 @see setTorchBrightness:
 */
-(void)applyTorchSettings;

/*!
 @enum CD_Resolution
 
 @brief Provides different resolution options CortexDecoder supports
 
 @discussion This is the type define for setting the image resolution that is passed to the decoder.
 
 @field CD_Resolution_1920x1080 Default resolution if supported by device.
 
 @field CD_Resolution_1280x720
 
 @field CD_Resolution_640x480
 
 @field CD_Resolution_352x288
 
 @field CD_Resolution_2592x1936
 
 @field CD_Resolution_3840x2160
 
 @see setDecoderResolution:
 @see isDecoderResolutionSupported:
 */
typedef enum {
    CD_Resolution_1920x1080,
    CD_Resolution_1280x720,
    CD_Resolution_640x480,
    CD_Resolution_352x288,
    CD_Resolution_2592x1936,
    CD_Resolution_3840x2160
} CD_Resolution;

/*!
 @brief This method sets the active resolution mode.

 @param resolution Resolution to use for decoding.
 
 @remarks Default is CD_Resolution_1920x1080
 
 @see CD_Resolution
 @see isDecoderResolutionSupported:
 */
-(void)setDecoderResolution:(CD_Resolution)resolution;

/*!
 @brief This method queries the active camera to see if it supports the specified resolution.

 @param resolution Resolution to check if it's supported by device camera.
 
 @see CD_Resolution
 @see setDecoderResolution:
 */
-(BOOL)isDecoderResolutionSupported:(CD_Resolution)resolution;

/*!
 @brief This method retrieves the size of the image that the decoder is using as a CGSize.

 @return A CGSize that contains the image size.
 */
-(CGSize)currentSizeOfDecoderVideo;

/*!
 @brief This method will enable/disable video frame capturing.

 @param enable  Set to YES to enable video capturing, otherwise set to NO to disable video capturing.
 
 @see isVideoCapturing
 */
-(void)enableVideoCapture:(BOOL)enable;

/*!
 @brief This method will enable/disable passing of video frames to decoder for processing.

 @param enable  Set to YES to enable decode processing, otherwise set to NO to disable decode processing.
 
 @remarks Device will still continue capturing video frames, which might affect battery performance.
 */
-(void)enableDecoding:(BOOL)enable;

/*!
 @brief This method will disable the torch for the current camera type.
 
 @see CD_Torch
 @see setTorch:
 @see setTorchBrightness:
 @see applyTorchSettings
 @see hasTorch
 
 */
-(void)disableTorch;

/*!
 @brief This method will determine if the current camera type supports a torch.
 
 @return Returns BOOL value indicating if device has torch support or not.
 
 @see CD_Torch
 @see setTorch:
 @see setTorchBrightness:
 @see applyTorchSettings
 @see disableTorch
 */
-(BOOL)hasTorch;

/*!
 @brief Tell the decoder how many barcodes to try and decode from an image.

 @param decodeCnt  Defaults to 1. Can specify up to 20.
 
 @see matchDecodeCountExactly:
 */
-(void)setNumberOfDecodes:(int)decodeCnt;

/*!
 @brief If not set to match exactly then the decoder will try and decode up to the number of barcodes set using API setNumberOfDecodes.
 
 @param bMatchDecodeCnt  Defaults to YES if API not called.
 
 @see setNumberOfDecodes:
 */
-(void)matchDecodeCountExactly:(BOOL)bMatchDecodeCnt;

/*!
 @brief Set the decoder targeting tolerance level.

 @param toleranceLevel  Defaults to 10 which specifies infinite tolerance. Tolerance level of value N 0 thru 9 will expand
        the tolerance targeting bounding box by N times half of the barcode height in all four directions.
 */
-(void)setDecoderToleranceLevel:(int)toleranceLevel;

/*!
 @brief Set the audio sound file to be played by library on successful decode.
 
 @discussion This API can be used to change the audio to be played on successful decode.
            By default, CortexDecoderLibrary will play an audio sound on successful barcode decode.

 @param soundFile  Must be an audio file accessible from app's MainBundle.
        Only .wav, .car, or .aif audio file formats supported.
 
 @remarks soundFile String needs to be full path for the sound file instead of just sound file name.
 
 @see enableBeepPlayer:
 */
-(void)setAudioSoundFile:(NSString *)soundFile;

/*!
 @brief Set the public sector configuration string.  Allows customization of returned data when scanning a PDF417 drivers license.

 @param configStr  Must be a valid configuration string.  Set to empty string to disable public sector parsing feature of CortexDecoder.
 */
-(void)setPublicSectorConfigStr:(NSString *)configStr;

/*!
 @brief Call this API to determine if CortexDecoder is currently capturing video frames from the camera.

 @return BOOL Returns YES if CortexDecoder is currently capturing video frames, otherwise returns NO.
 
 @see enableVideoCapture:
 */
-(BOOL)isVideoCapturing;

/*!
 @enum CD_DEVICE_TYPE

 @brief Different Device Type modes supported by CortexDecoder.
 
 @discussion This is the type defines for controlling different Device Type options.
            CortexDecoder supports application to be developed either as a standalone application (CD_IPHONE) or as an application using our Sled Accessories (CD_CR4300).
            CD_DEVICE_TYPE is mostly use with API setDeviceType: to indicate CortexDecoder of how application is currently intended to work.
 
 @field CD_IPHONE       Indicates CortexDecoder that application is being used as standalone iPhone. Used when application is CortexScan with/without CR4300N.
 
 @field CD_CR4300       Indicates CortexDecoder that application is being used as CR4300. CortexDecoder will apply CR4300 specific settings.
 
 @see setDeviceType:
 
 */
typedef enum {
    CD_IPHONE,
    CD_CR4300
}CD_DEVICE_TYPE;

/*!
 @brief In general this is used to optimize camera performance when using CortexDecoder SDK along with a Code CR4300 sled.

 @param deviceType Indicate to CortexDecoder if using Code CR4300 sled.
 
 @remarks Defaults to CD_IPHONE if API not called.
 
 @see CD_DEVICE_TYPE
 */
-(void)setDeviceType:(CD_DEVICE_TYPE)deviceType;

/*!
 @brief On a successful decode call this method to get an array of
                BarcodeBounds(encoded as NSValue) that describes the bounding boxes of all decoded barcodes.
 
 @return Returns an NSArray of type BarcodeBounds that contains points for all barcodes decoded.
 
 @remarks SDK can handle drawing boundary box on decoded barcode internally.
            Use API enableHighlightScannedBarcode for the same.
 
 @see enableHighlightScannedBarcode:
 */
-(NSArray *)getBarcodeCornersArray;

/*!
 @brief This method can be used to enable/disable highlight scanned barcode.
 
 @param enable Indicates to CortexDecoder if it should enable/disable
        highlighting scanned barcode. Pass YES to enable and NO to disable the feature.
 
 @discussion This methods draws a green boundary box on barcode that is decoded. SDK
            handles calculating the area and drawning boundary box for decoded barcode.
 
 @remarks If need to control behaviour of this feature use API getBarcodeCornersArray.
 
 @see getBarcodeCornersArray
 @see isHighlightScannedBarcodeEnabled
 
 @since version 3.4.5
 */
-(void)enableHighlightScannedBarcode:(BOOL)enable;

/*!
 @brief This method can be used to determine if Highlight Scanned Barcode is currently enabled or disabled.
 
 @return BOOL Returns YES is feature is enable and NO if its disabled.
 
 @see enableHighlightScannedBarcode:
 
 @since version 3.4.5
 */
-(BOOL)isHighlightScannedBarcodeEnabled;

/*!
 @brief This method enables or disables the beep sound after a successful scan.
 
 @param enable Used to enable/disable Beep sound on event of successful barcode decoding.
 
 @see setAudioSoundFile:
 */
-(void)enableBeepPlayer:(BOOL)enable;

/*!
 @brief This method can be used to determine if CortexDecoder license has expired.
 
 @return int Returns an interger value.
 
 @remarks Value 908 indicates that CortexDecoder license has expired.
 */
-(int) getDecodeVal;

/*!
 @brief Optional API which can be used to activate Enterprise CortexDecoderLibrary (EDK).
 
 @discussion This method is used to force CortexDecoder to make a callback to protocol method CortexDecoderLibrary::configurationKeyData:
 
 @remarks CortexDecoder makes a callback to method CortexDecoderLibraryDelegate::configurationKeyData: when CortexDecoder delegate is set.
            It also makes a callback when supported CD_SledAccessoryDeviceType is connected or disconnected (based on Accessory Device).
 
 @see CortexDecoderLibraryDelegate::configurationKeyData:
 @see CortexDecoderLibraryDelegate::receivedConfigFileActivationResult:
 @see CortexDecoderLibraryDelegate::receivedConfigFileError:
 */
-(void)makeCallbackForConfigurationKeyData;

/*!
 @brief This method is used to start/stop video Capturing based on device motion. Starts video when motion is detected otherwise stops the video. Helps improve battery performance.
 
 @param enable Used to enable motion based video capturing. YES starts motion based video capturing. NO stops motion based video capturing.
 */
-(void)motionBasedPerformance:(BOOL)enable;

/*!
 @brief This method returns an NSMutableDictionary that contains list of CD_SymbologyType Symbology that are licensed.
 
 @return NSMutableDictionary List of CD_SymbologyType indicating symbologies licensed, where CD_SymbologyType is key with its value set to "1".
 
 @remarks Unlicensed Symbologies will not be present in NSMutableDictionary.
 
 @see CortexDecoderLibraryDelegate::CD_SymbologyType
 
 @since version 3.0
 */
-(NSMutableDictionary*)getLicensedSymbologies;

/*!
 @brief This method returns an NSMutableDictionary that contains list of CD_PerformanceFeatures that are licensed.
 
 @return NSMutableDictionary List of CD_PerformanceType indicating performance features that are licensed, where CD_PerformanceType is key with its value set to "1".
 
 @remarks Unlicensed Performance features will not be present in NSMutableDictionary.
 
 @see CD_PerformanceType
 
 @since version 3.0
 */
-(NSMutableDictionary*)getLicensedPerformanceFeatures;

/*!
 @enum CD_DataParsingType
 
 @brief Represents information about Data Parsing types supported by CortexDecoder.
 
 @discussion Used to select Data Parsing type to be used when API setDataParsingProperty:withConfigString: is used
 
 @field CD_DataParsing_Disable          Indicates CortexDecoder to disable Data Parsing.
 
 @field CD_DataParsing_DLParsing        Indicates CortexDecoder to enable DL Parsing.
 
 @field CD_DataParsing_StrMatchReplace  Indicates CortexDecoder to enable String Matching and Replacing.
 
 @field CD_DataParsing_GS1Parsing       Indicates CortexDecoder to enable GS1 Parsing.
 
 @field CD_DataParsing_UDIParsing       Indicates CortexDecoder to enable UDI Parsing.
 
 @field CD_DataParsing_ISOParsing       Indicates CortexDecoder to enable ISO Parsing.
 
 @see setDataParsingProperty:withConfigString:
 @see getCurrentDataParsingType
 @see getConfigStringForDataParsingType:
 
 @since version 3.0
 */
typedef enum{
    CD_DataParsing_Disable,
    CD_DataParsing_DLParsing,
    CD_DataParsing_StrMatchReplace,
    CD_DataParsing_GS1Parsing,
    CD_DataParsing_UDIParsing,
    CD_DataParsing_ISOParsing,
    CD_DataParsing_JSONDLParsing
} CD_DataParsingType;

/*!
 @brief This method is used to select a Data Parsing option. Defaults to CD_DataParsing_Disable.
 
 @param type Indicate to CortexDecoder data parsing type to be used.
 
 @param configString Provides the configuration string for the data parsing type selected.
 
 @remarks Set to CD_DataParsing_Disable and empty string to disable Data Parsing.
 
 @see CD_DataParsingType
 @see getCurrentDataParsingType
 @see getConfigStringForDataParsingType:
 
 @since version 3.0
 */
-(void)setDataParsingProperty:(CD_DataParsingType)type withConfigString:(NSString*)configString;

/*!
 @brief This method returns CD_DataParsingType that is currently being used. Data Parsing is set using API setDataParsingProperty.
 
 @return CD_DataParsingType   Current CD_DataParsingType being used.
 
 @see setDataParsingProperty:withConfigString:
 @see CD_DataParsingType
 @see getConfigStringForDataParsingType:
 
 @since version 3.1
 */
-(CD_DataParsingType)getCurrentDataParsingType;

/*!
 @brief This method returns latest NSString used for CD_DataParsingType passed in the API.
 
 @return NSString   That was last used or is currently being used for a given CD_DataParsingType.
 
 @see setDataParsingProperty:withConfigString:
 @see CD_DataParsingType
 @see getCurrentDataParsingType
 
 @since version 3.1
 */
-(NSString*)getConfigStringForDataParsingType:(CD_DataParsingType)type;

/*!
 @brief This method is used to select a Data Formatting option.
 
 @param formatString Provides CortexDecoder with the data formatting string to be used for decoding.

 @see isDataFormattingEnabled
 @see getConfigStringForDataFormatting
 
 @since version 3.0
 */
-(void)setDataFormatting:(NSString*)formatString;

/*!
 @brief This method returns BOOL indicating whether Data Formatting is currently Enabled/Disabled.
 
 @return BOOL   Indicate if Data Formatting is currently enabled/disabled.
 
 @see setDataFormatting:
 @see getConfigStringForDataFormatting
 
 @since version 3.1
 */
-(BOOL)isDataFormattingEnabled;

/*!
 @brief This method returns NSString that is currently or was last used for Data Formatting.
 
 @return NSString   NSString used for formatting decode data.
 
 @see setDataFormatting:
 @see isDataFormattingEnabled
 
 @since version 3.1
 */
-(NSString*)getConfigStringForDataFormatting;

/*!
 @enum CD_DPMType
 
 @brief Represents information about DPM types supported by CortexDecoder.
 
 @discussion Provides information about DPM types.
 
 @field CD_DPM_Disabled         Indicates CortexDecoder to disable DPM decoding.
 
 @field CD_DPM_DarkOnLight      Indicates CortexDecoder to decode Dark on light DPM barcodes.
 
 @field CD_DPM_LightOnDark      Indicates CortexDecoder to decode Light on dark DPM barcodes.
 
 @field CD_DPM_LaserChemEtch    Indicates CortexDecoder to decode laser DPM barcodes.
 
 @see setDPMProperty:
 @see getCurrentDPMType
 
 @since version 3.0
 */
typedef enum{
    CD_DPM_Disabled,
    CD_DPM_DarkOnLight,
    CD_DPM_LightOnDark,
    CD_DPM_LaserChemEtch
}CD_DPMType;

/*!
 @brief This method is used to select DPM type. Defaults to CD_DPM_Disabled.
 
 @param type Indicate to CortexDecoder DPM type to be used for decoding DPM barcodes.
 
 @see CD_DPMType
 @see getCurrentDPMType
 
 @since version 3.0
 */
-(void)setDPMProperty:(CD_DPMType)type;

/*!
 @brief This method returns CD_DPMType indicating which CD_DPMType is currently being use.
 
 @return CD_DPMType   Indicates which CD_DPMType is currently being used.
 
 @see setDPMProperty:
 @see CD_DPMType
 
 @since version 3.1
 */
-(CD_DPMType)getCurrentDPMType;

#pragma mark - Licenseing API's -

/*!
 @brief  This method is used to pass license key to activate CortexDecoder.
 
 @param licenseKey License Key in NSString format to activate license on a particular device.
 
 @remarks Activation result is send back via callback receivedLicenseActivationResult:withMessage:
 
 @remarks On successful license key validation, CortexDecoder will enable commonly used licensed symbologies.
 
 @see CortexDecoderLibraryDelegate::CD_License_Activation_Result
 */
-(void)activateLicenseKey:(NSString*)licenseKey;

/*!
 @brief This method is used to validate an existing license on device.
 
 @return BOOL YES/NO indicating if license was successfully validated.
 
 @remarks CortexDecoder will send a callback to receivedLicenseActivationResult:withMessage: indicating license status.
 
 @remarks This API should be used everytime an application is started, particularly in viewDidAppear method.
 This will make sure that license file present on device activates license features.
 
 @remarks On successful license key validation, CortexDecoder will retrieve last saved settings. NOTE: For this to work application needs to use individual symbology API's added in version 3.1.
 
 @see CortexDecoderLibraryDelegate::CD_License_Activation_Result
 @see CortexDecoderLibraryDelegate::receivedLicenseActivationResult:withMessage:
 */
-(BOOL)validateLicenseKey;

#pragma mark - Test Analysis -
/*!
 @brief    This API is used to reset number of frames it takes to successfully decode a barcode.
                It resets the frame count from last successful/failed scan attempt.
 
 @remarks Needs to be used in conjunction with API captureTestData.
 
 @see captureTestData:
 */
- (void)resetTestDataForFrame;

/*!
 @brief This method is used to enable/disable capture test data mode.
 
 @discussion Meta data of decode time, number of frame for a specific try,
                symbology type and camera settings are saved for each frame in a txt document within app sandbox.
 
 @param enable Yes to enable. Defaults to No.
 
 @remarks API resetTestDataForFrame must be called when a new attempt to decode a barcode is made.
 
 @see resetTestDataForFrame
 */
- (void)captureTestData:(BOOL)enable;

#pragma mark - SLED Hardware API's -

/*!
 @enum CD_SledAccessoryDeviceType
 
 @brief Represents information about Code Sled Accessories.
 
 @discussion Provides information about Code Sled Accessory connected when API getSledAccessoryConnected is called.
 
 @field Sled_AccessoryTypeNone  Indicates no Sled Accessory connected currently.
 
 @field Sled_AccessoryTypeCR4300    Indicates CR4300 Sled Accessory connected currently.
 
 @field Sled_AccessoryTypeCR4300N   Indicates CR4300N Sled Accessory connected currently.
 
 @see getSledAccessoryConnected
 
 @since version 3.0
 */
typedef enum{
    Sled_AccessoryTypeNone,
    Sled_AccessoryTypeCR4300,
    Sled_AccessoryTypeCR4300N,
    Sled_AccessoryTypeCR7018,
    Sled_AccessoryTypeCR4405
} CD_SledAccessoryDeviceType;

/*!
 @brief This method is used to create a connection with Code sleds.
 
 @discussion By default library will create and destroy this connection when a
                code sled is connected or disconnected from device.
                But this API can be used if user manually needs to manage
                connected in some circumstances.
 
 @see destroySledHardwareConnection
 
 @since version 3.3.6
 */
-(void)createSledHardwareConnection;

/*!
 @brief This method is used to destory a connection with current connected Code sled.
 
 @discussion By default library will create and destroy this connection when a
                code sled is connected or disconnected from device.
                But this API can be used if user manually needs to manage
                connected in some circumstances.
 
 @see createSledHardwareConnection
 
 @since version 3.3.6
 */
-(void)destroySledHardwareConnection;

/*!
 @brief This method is used to get current Sled Accessory connected to device
 
 @return CD_SledAccessoryDeviceType   Current Code Sled Accessory connected to device
 
 @see CD_SledAccessoryDeviceType
 
 @remarks This API will establish connection to sled's if its current connected
            but hardware connection was not setup previously.
 
 @since version 3.0
 */
-(CD_SledAccessoryDeviceType)getSledAccessoryConnected;


/*!
 @brief This method is used to get Battery Health Status for connected Code Accessory.
 
 @discussion Provides information about how good Battery Health is for the
                connected Battery on CR7018 case. A new Battery will always
                return 100, indicating best Health.
 
 @return NSString Contains String with value between 0-100, indicating Battery
            Health Status.
 
 @remarks Battery Health Status is returned only for CR7000 accessory.
 
 @since version 3.3
 */
-(NSString*)getSledAccessoryBatteryHealthStatus;

/*!
 @brief This method is used to get Battery Deployment Date for connected Code Accessory.
 
 @discussion Deployment Date is to provide an idea as to when current Battery
                was installed in CR7018 case.
 
 @return NSString Contains String value indicating Battery Deployment Date in
            MMYY format.
 
 @remarks Battery Deployment Date is only return for CR7000 accessory.
 
 @since version 3.3
 */
-(NSString*)getSledAccessoryBatteryDeploymemtDate;

/*!
 @brief This method is used to get Battery Serial Number for connected Code
            Accessory.
 
 @discussion Provides Battery Serial value of current Battery attached to CR7018 case.
 
 @return NSString Contains String value indicating Battery Serial Number.
 
 @remarks Battery Serial Number is only return for CR7000 accessory.
 
 @since version 3.3
 */
-(NSString*)getSledAccessoryBatterySerialNumber;

/*!
 @brief This method is used to get Case Serial Number for connected Code Accessory.
 
 @discussion Provides Case Serial Number of current Code case attached to device.
 
 @return NSString Contains String value indicating Case Serial Number.
 
 @since version 3.3
 */
-(NSString*)getSledAccessorySerialNumber;

/*!
 @brief This method is used to get Case Firmware Number for connected Code Accessory.
 
 @discussion Provides Case Firmware Number of current Code case attached to device.
 
 @return NSString Contains String value indicating Case Firmware Number.
 
 @since version 3.3
 */
-(NSString*)getSledAccessoryFirmwareNumber;

#pragma mark - Image Saving Options -

/*!
 @enum CD_ImageSavingType
 
 @brief Different Image Saving modes supported by CortexDecoder.
 
 @discussion This is the type defines for controlling different image saving options.
 
 @field CD_ImageSaving_None         Indicates CortexDecoder not to save any image.

 @field CD_ImageSaving_Normal       Indicates CortexDecoder to save all images, that is, all frames which decoder tries to decode.
 
 @field CD_ImageSaving_Successful   Indicates CortexDecoder to save successful images, that is, only frames which decoder successfully deocdes.
 
 @field CD_ImageSaving_Failed       Indicates CortexDecoder to save failed images, that is, only frames which decoder fails to deocde.
 
 @field CD_ImageSaving_OnError      Indicates CortexDecoder to save images only when fatal error occurs. 
 
 @field CD_ImageSaving_Sequence     Indicates CortexDecoder to save last 20 sequential images.
 
 @field CD_ImageSaving_Manual       Indicates CortexDecoder to save only one image when API captureCurrentImageInBuffer is called. This saves image in Photos app.
 
 @remarks CD_ImageSaving_Manual saves image in Photos app while all other options saves images within app sandbox.
 @remarks CD_ImageSaving_Manual is to be used only when API setDeviceType is set to CD_IPHONE.
 @remarks CD_ImageSaving_Sequence is to be used only when API setDeviceType and setVideoOutputFormat is set to CD_CR4300 and CD_VideoOutputFormat_8BitGrayScale respectively.
 
 @see captureCurrentImageInBuffer
 @see enableImageSaving:
 @see deleteImages
 @see setVideoOutputFormat:
 @see setDeviceType:
 
 @since version 3.0
 */

typedef enum{
    CD_ImageSaving_None,
    CD_ImageSaving_Normal,
    CD_ImageSaving_Successful,
    CD_ImageSaving_Failed,
    CD_ImageSaving_OnError,
    CD_ImageSaving_Sequence,
    CD_ImageSaving_Manual
} CD_ImageSavingType;

/*!
 @brief This method is used to select imageSaving type.
 
 @discussion Defaults to CD_ImageSaving_None. It can be used when trying to debug any potential issue in CortexDecoder.
 
 @param imageSavingType Indicate to CortexDecoder imageSaving type to be used.
 
 @see CD_ImageSavingType
 
 @since version 3.0
 */
-(void)enableImageSaving:(CD_ImageSavingType)imageSavingType;

/*!
 @brief This method will capture the current image in the buffer and store it in the camera roll.
 
 @remarks For this to work API enableImageSaving must be set to CD_ImageSaving_Manual.
 
 @see CD_ImageSavingType
 @see enableImageSaving:
 */
-(void)captureCurrentImageInBuffer;

/*!
 @brief This method is used to delete images saved within application sandbox.
 
 @return int Returns int value indicating number of images deleted. Returns 0 if no images are deleted.
 
 @see CD_ImageSavingType
 @see enableImageSaving:
 @see captureCurrentImageInBuffer
 
 @since version 3.0
 */
-(int)deleteImages;

/*!
 @brief This method enables & disables the capture of the image that was used for
        decoding the barcode. This method will put the decoder in debug mode.
 
 @param enable YES to enable.  Default value is disabled.
 
 @remarks This comes at a cost to performance and only works on iOS 8 and above.
 
 @deprecated This API was deprecated with CortexDecoderLibrary version 3.0. Use API enableImageSaving: with CD_ImageSaving_Normal/CD_ImageSaving_Manual attribute instead.
 */
-(void)enableScannedImageCapture:(BOOL)enable __attribute__ ((deprecated("This API was deprecated with CortexDecoderLibrary version 3.0. Use API enableImageSaving: with CD_ImageSaving_Normal/CD_ImageSaving_Manual attribute instead.")));

/*!
 @brief This method enables & disables the capture of the image that was used for
        decoding the barcode.
 
 @discussion This method will put the decoder in debug mode. This
                does not add any overhead to performance and only works on iOS 8 and above.
 
 @param enable YES to enable.  Default value is disabled.
 
 @deprecated This API was deprecated with CortexDecoderLibrary version 3.0. Use API enableImageSaving: with CD_ImageSaving_Sequence attribute instead..
 */
-(void)enableImageCapturingToBuffer:(BOOL)enable __attribute__ ((deprecated("This API was deprecated with CortexDecoderLibrary version 3.0. Use API enableImageSaving: with CD_ImageSaving_Sequence attribute instead.")));

/*!
 @brief This method returns Zoom ratios supported by the device running.
 
 @return Returns NSMutableArray with 2 value, ObjectAtIndex:0 is Minimum Zoom value supported while ObjectAtIndex:1 is Maximum Zoom value.
 
 @see setCameraZoom:
 
 @since version 3.1
 */
-(NSMutableArray*)getZoomRatios;

/*!
 @brief This method sets a Zoom Factor for current Camera.
 
 @param zoomValue Specifies Zoom Factor for active Camera in CGFloat.
 
 @see getZoomRatios
 
 @since version 3.1
 */
-(void)setCameraZoom:(CGFloat)zoomValue;

/*!
 @brief This method is used to enable Multi Scanning functionality in CortexDecoder.
 
 @discussion This allows application to scan multiple barcodes using multiple frames.
                CortexDecoder will only decode unique barcode data. CortexDecoder returns the data
                when it decodes all unique barcodes.
 
 @param enable Enables/Disables the Multi Scan feature.
 
 @remarks API setNumberOfDecodes is used to specify number of barcodes to be scanned.
 @remarks App needs to support callback receivedMultiDecodedData:andType:
 
 @see setNumberOfDecodes:
 @see CortexDecoderLibraryDelegate::receivedMultiDecodedData:andType:
 @see CortexDecoderLibraryDelegate::multiFrameDecodeCount:
 
 @since version 3.1
 */

-(void)enableMultiFrameDecoding:(BOOL)enable;
/*!
 @enum CD_DecoderSecurityLevel
 
 @brief Represents information about how CortexDecoder tries to decode symbologies.
 
 @discussion Provides information about different CortexDecoder modes, which impacts how aggressive the decoding performance should be.
 
 @field CD_DecoderSecurityLevel0        Default, most agressive decoding
 
 @field CD_DecoderSecurityLevel1        Reduced aggressiveness for poor quality 1D barcode
 
 @field CD_DecoderSecurityLevel2        Lowest aggressiveness to avoid misdecode of poor quality 1D barcode
 
 @field CD_DecoderSecurityLevel3        Conditions signal quality for CR4300 mode
 
 @field CD_DecoderSecurityLevel11       Reduced aggressiveness for low resolution 1D barcode
 
 @field CD_DecoderSecurityLevel12       Lowest aggressiveness to avoid misdecode of low resolution 1D barcode
 
 @field CD_DecoderSecurityLevel21       Attempt to correct and decode poorly printed characters
 
 @see setDecoderSecurityLevel:
 
 @since version 3.1
 */
typedef enum{
    CD_DecoderSecurityLevel0,
    CD_DecoderSecurityLevel1,
    CD_DecoderSecurityLevel2,
    CD_DecoderSecurityLevel3,
    CD_DecoderSecurityLevel11,
    CD_DecoderSecurityLevel12,
    CD_DecoderSecurityLevel21
}CD_DecoderSecurityLevel;

/*!
 @brief This method is used to change the aggressiveness for CortexDecoder. It impacts the performance of CortexDecoder based on param value used.
 
 @param securityLevel Specifices securityLevel/aggressiveness for CortexDecoder.
 
 @see CD_DecoderSecurityLevel
 
 @since version 3.1
 */
-(void)setDecoderSecurityLevel:(CD_DecoderSecurityLevel)securityLevel;

/*!
 @brief This method is used to receive Number of barcode decodes in a minute.
            App needs to support callback receivedDecodeCountPerMinData:
 
 @param enable Indicates to CortexDecoder whether to enable/disable Decode count per minute functionality.
 
 @remarks Defaults to Disable.
 
 @see CortexDecoderLibraryDelegate::receivedDecodeCountPerMinData:
 
 @since version 3.1
 */
-(void)enableDecodeCountPerMin:(BOOL)enable;

@end
#pragma mark - ImageScan Delegate -
/*!
 @protocol ImageScanDelegate
 
 @brief This is the protocol for handeling Image Scan callbacks.
 */
@protocol ImageScanDelegate<NSObject>

/*!
 @brief Protocol method that is called when the decoder has successfully decoded barcode(s).
 
 @param data NSArray that contains NSData objects.
 
 @param type NSArray that contains CD_SymbologyType objects.
 
 @see CD_SymbologyType
 
 @since version 3.3.1
 */
-(void)receivedMultiDecodedData:(NSArray*)data andType:(NSArray *)type;

/*!
 @brief Protocol method that is called when the decoder has successfully decoded a barcode.
 
 @param data The data that the decoder has read.
 
 @param type The symbology type of the barcode that was read.
 
 @see CD_SymbologyType
 
 @since version 3.3.1
 */
-(void)receivedDecodedData:(NSData*)data andType:(CD_SymbologyType)type;

/*!
 @brief Protocol method that is called when API activateLicenseKey is called in your application.
 
 @param code CD_License_Activation_Result contains a CD_License_Activation_Result enum which details about license activation result.
 
 @param message NSString that contains a brief descripition about license activation result.
 
 @remarks Do not call activateLicenseKey: API from within this callback. Application will enter an infinte loop and eventually crash.
 
 @see CD_License_Activation_Result
 @see ImageScan::activateLicenseKey:
 
 @since version 3.3.1
 */
@optional
-(void)receivedLicenseActivationResult:(CD_License_Activation_Result)code withMessage:(NSString*)message;

/*!
 @brief Protocol method used to activate Enterprise CortexDecoderLibrary license (EDK).
 
 @discussion Protocol method that is called when the decoder needs Configuration Key (EDK Key) and Customer ID.
 When both data, that is, Configuration Key (EDK Key) and Customer ID are valid decoder will activate configuration Key (EDK Key) License.
 
 @param requestedData NSString that will either be NSString "configurationKey" (EDK Key) or "customerID".
 When NSString is equal to configurationKey (EDK Key) decoder is expecting configuration Key Data to be returned.
 When NSString is equal to customerID decoder is expecting customer ID to be returned.
 
 @return NSString This is either a Configuration Key (EDK Key) and Customer ID that is returned to CortexDecoder for license activation.
 
 @see receivedConfigFileActivationResult:
 @see receivedConfigFileError:
 
 @since version 3.3.2
 */
@optional
-(NSString*)configurationKeyData:(NSString*)requestedData;

/*!
 @brief Protocol method used to inform if Enterprise license (EDK) activation was successful or not.
 
 @discussion Protocol method is called when the decoder either activates/deactivates configuration Key License (EDK license).
 
 @param licenseActivated  Contains BOOL value indicating if configuration Key License is activated/deactivated.
 YES means configuration Key License is actived.
 NO means configuration Key License is deactivated.
 
 @see configurationKeyData:
 
 @since version 3.3.2
 */
@optional
-(void)receivedConfigFileActivationResult:(BOOL)licenseActivated;

/*!
 @brief Protocol method which shares detailed error message when Enterprise license (EDK) activation was not successful.
 
 @discussion Protocol method is called when an error is occured while trying to activate configuration Key License (EDK License).
 
 @param error NSString that contains NSString explaining what error is occured.
 
 @see configurationKeyData:
 
 @since version 3.3.2
 */
@optional
-(void)receivedConfigFileError:(NSString*)error;
@end

#pragma mark - ImageScan Interface -
/*!
 @brief This is the interface class for working with the Cortex Decoder Library.
 All public methods for ImageScan are defined within this class.
 */
@interface ImageScan : NSObject

/*!
 @brief This is the delegate for the ImageScan.
 
 @discussion All callbacks will be done via the delegate. The delegate should implement the
 "ImageScanDelegate" protocol.
 */
@property (weak,nonatomic) id<ImageScanDelegate> delegate;

/*!
 @brief  Used to get the shared instance of the ImageScan class.
 
 @return The singleton instance of the ImageScan class.
 
 @since version 3.3.1
 */
+(ImageScan*)sharedObject;

/*!
 @brief Used to deallocate the shared instance created for CortexDecoderLibrary class.
 
 @since version 3.3.1
 */
-(void)closeSharedObject;

/*!
 @brief This method translates a CD_SymbologyType type to a NSString.
 
 @param type The CD_SymbologyType that you want returned as a string.
 
 @return A NSString representing the CD_SymbologyType passed to the method
 
 @see CortexDecoderLibraryDelegate::CD_SymbologyType
 
 @since version 3.3.1
 */
+(NSString*)stringFromSymbologyType:(CD_SymbologyType)type;

/*!
 @brief This method is used to pass a CMSampleBufferRef containing buffer for
        image to be decoded.
 
 @discussion The CMSampleBufferRef is camera output when using AVFoundation to
            capture frames.
 
 @param sampleBuffer passed to decoder for decoding. It is expected to be in grayscale.
 
 @remarks CMSampleBufferRef needs to be grayscale.
 
 @since version 3.3.1
 */
-(void)doDecode:(CMSampleBufferRef)sampleBuffer;

/*!
 @brief This method sets a timeout for how long the decoder will process a video frame.
 
 @discussion If this timeout is reached the decoder will continue processing on the next video frame if available.
 
 @param milliseconds This should be a positive integer representing the
 timeout in milliseconds. If set to 0 no timeout will be used.
 
 @since version 3.3.1
 */
-(void)decoderTimeLimitInMilliseconds:(int)milliseconds;

/*!
 @brief Tell the decoder how many barcodes to try and decode from an image.
 
 @param decodeCount Defaults to 1. Can specify up to 20.

 @see matchDecodeCountExactly:
 
 @since version 3.3.1
 */
-(void)setNumberOfDecodes:(int)decodeCount;

/*!
 @brief If not set to match exactly then the decoder will try and decode up to the number of barcodes set using API setNumberOfDecodes.
 
 @param bMatchDecodeCnt  Defaults to YES if API not called.
 
 @see setNumberOfDecodes:
 
 @since version 3.3.1
 */
-(void)matchDecodeCountExactly:(BOOL)bMatchDecodeCnt;

/*!
 @brief  This method is used to pass license key to activate CortexDecoder.
 
 @param licenseKey License Key in NSString format to activate license on a particular device.
 
 @remarks Activation result is send back via callback receivedLicenseActivationResult:withMessage:
 
 @remarks On successful license key validation, CortexDecoder will enable commonly used licensed symbologies.
 
 @see CortexDecoderLibraryDelegate::CD_License_Activation_Result
 
 @since version 3.3.1
 */
-(void)activateLicenseKey:(NSString*)licenseKey;

/*!
 @brief This method is used to validate an existing license on device.
 
 @return BOOL YES/NO indicating if license was successfully validated.
 
 @remarks CortexDecoder will send a callback to receivedLicenseActivationResult:withMessage: indicating license status.
 
 @remarks This API should be used everytime an application is started, particularly in viewDidAppear method.
 This will make sure that license file present on device activates license features.
 
 @remarks On successful license key validation, ImageScan will retrieve last saved settings. NOTE: For this to work application needs to use individual symbology API's added in version 3.1.
 
 @see CortexDecoderLibraryDelegate::CD_License_Activation_Result
 @see ImageScanDelegate::receivedLicenseActivationResult:withMessage:
 
 @since version 3.3.1
 */
-(BOOL)validateLicenseKey;

/*!
 @brief On a successful decode call this method to get an array of
 BarcodeBounds(encoded as NSValue) that describes the bounding boxes of all decoded barcodes.
 
 @return Returns an NSArray of type BarcodeBounds that contains points for all barcodes decoded.
 
 @since version 3.3.1
 */
-(NSArray *)getBarcodeCornersArray;

/*!
 @brief Optional API which can be used to activate Enterprise CortexDecoderLibrary (EDK).
 
 @discussion This method is used to force CortexDecoder to make a callback to protocol method ImageScan::configurationKeyData:
 
 @remarks ImageScan makes a callback to method ImageScanDelegate::configurationKeyData: when ImageScan delegate is set.
 It also makes a callback when supported CD_SledAccessoryDeviceType is connected or disconnected (based on Accessory Device).
 
 @see ImageScanDelegate::configurationKeyData:
 @see ImageScanDelegate::receivedConfigFileActivationResult:
 @see ImageScanDelegate::receivedConfigFileError:
 
 @since version 3.3.2
 */
-(void)makeCallbackForConfigurationKeyData;

/*!
 @brief This method returns the version of the Cortex Decoder.
 
 @return A NSString containing the decoder version.
 
 @since version 3.3.2
 */
-(NSString*)decoderVersion;

/*!
 @brief This method returns the license level of the Cortex Decoder.
 
 @return A NSString containing the license level of the Cortex Decoder.
 
 @since version 3.3.2
 */
-(NSString*)decoderVersionLevel;

/*!
 @brief This method returns the version of the Cortex Decoder Library.
 
 @return A NSString containing the library version.
 
 @since version 3.3.2
 */
-(NSString*)libraryVersion;

/*!
 @brief This method returns the version of the Cortex Decoder SDK
 
 @return A NSString containing the sdk version.
 
 @since version 3.3.2
 */
-(NSString*)sdkVersion;

/*!
 @brief This method returns an NSMutableDictionary that contains list of CD_SymbologyType Symbology that are licensed.
 
 @return NSMutableDictionary List of CD_SymbologyType indicating symbologies licensed, where CD_SymbologyType is key with its value set to "1".
 
 @remarks Unlicensed Symbologies will not be present in NSMutableDictionary.
 
 @see CortexDecoderLibraryDelegate::CD_SymbologyType
 
 @since version 3.0
 */
-(NSMutableDictionary*)getLicensedSymbologies;

@end

