CREATE MIGRATION m1oca45f422ruxssjo3ath47mxwg2u2o3ae5fii5saos2wrtt3zrha
    ONTO m1x6ogjdokijjuxykt5wcszaoly5wfrwvjcs5bfwl5vkaagwj5yhga
{
  ALTER TYPE activity::Activity {
      ALTER ACCESS POLICY IAllowUserToInsertItsActivityAndSelectItForDebouncing USING ((((GLOBAL default::userCurrent).id = .actor.id) ?? false));
  };
  ALTER TYPE activity::PrimitivePropertyChange {
      ALTER ACCESS POLICY IAllowSelectUpdateIfUserInSameOrganizationThanPrimitive USING ((((GLOBAL default::userCurrent).organization = .primitive.organization) ?? false));
  };
  ALTER TYPE default::PrimitiveProperty {
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING ((((GLOBAL default::userCurrent).organization = .organization) ?? false));
  };
  ALTER TYPE chat::Chat {
      ALTER ACCESS POLICY IAllowOnlyUserToAccessItsChats USING (NOT ((((GLOBAL default::userCurrent).id = .createdBy.id) ?? false)));
  };
  ALTER TYPE chat::Message {
      ALTER ACCESS POLICY IAllowOnlyUserToAccessItsMessages USING (NOT ((((GLOBAL default::userCurrent).id = .chat.createdBy.id) ?? false)));
  };
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING ((((GLOBAL default::userCurrent).organization = .organization) ?? false));
  };
  ALTER TYPE default::Invitation {
      ALTER ACCESS POLICY IAllowUserToSelectItsOwnInvitationIfItHasNotExpired USING (((((GLOBAL default::userCurrent).email = .email) ?? false) AND (.expiresAt > std::datetime_of_statement())));
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeCreated USING (((GLOBAL default::userCurrent = .createdBy) ?? false));
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeIsMemberOff USING ((((GLOBAL default::userCurrent).organization.id = .id) ?? false));
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization USING ((((GLOBAL default::userCurrent).organization = .organization) ?? false));
      ALTER ACCESS POLICY IGiveFullReadWriteAccessToUserRegardingItsOwnData USING ((((GLOBAL default::userCurrent).id = .id) ?? false));
  };
  ALTER TYPE design::Component {
      ALTER ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization USING ((((GLOBAL default::userCurrent).organization = .organization) ?? false));
  };
};
