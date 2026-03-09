@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency Value Help'
@Metadata.ignorePropagatedAnnotations: true


define view entity Zsa_Agency_VH 
as select from /DMO/I_Agency
{
    key AgencyID,
    Name,
    Street,
    PostalCode,
    City,
    CountryCode,
    PhoneNumber,
    EMailAddress,
    WebAddress,
    Attachment,
    MimeType,
    Filename,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Country
}
