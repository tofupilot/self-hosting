CREATE MIGRATION m1fr2ugzh7x3rku33otwbpfeifqcrdyx4rjm3kgy5v2xekd46hqmnq
    ONTO m1wlzluzff6nt264zv2tkkwsyw457z3lrtaxcklnqiw7zgytlomepa
{
  ALTER TYPE default::PrimitiveProperty {
      DROP ACCESS POLICY IAllowAPIUserToSelect;
  };
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY IAllowAPIUserToSelectAndInsert;
  };
  CREATE GLOBAL default::userCurrent := (SELECT
      default::User FILTER
          ((.id = GLOBAL default::currentUserId) ?? (.apiKey = GLOBAL default::apiKey))
  LIMIT
      1
  );
  ALTER TYPE default::PrimitiveProperty {
      ALTER LINK createdBy {
          SET default := (GLOBAL default::userCurrent);
      };
  };
  ALTER TYPE default::Primitive {
      ALTER LINK createdBy {
          SET default := (GLOBAL default::userCurrent);
      };
  };
  ALTER TYPE default::Organization {
      ALTER LINK createdBy {
          SET default := (GLOBAL default::userCurrent);
      };
      ALTER ACCESS POLICY IAllowSignedInUserToInsertNewOrganization USING (EXISTS (GLOBAL default::userCurrent));
      ALTER ACCESS POLICY IAllowSuperAdminToSelectOrganizationForAnalytics USING (((GLOBAL default::userCurrent).superAdmin ?? false));
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationHeHasBeenInvitedTo USING (EXISTS ((SELECT
          default::Invitation
      FILTER
          (((.email = (GLOBAL default::userCurrent).email) AND (.organization = default::Organization)) AND (.expiresAt > std::datetime_of_statement()))
      )));
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeCreated USING (((GLOBAL default::userCurrent ?= .createdBy) ?? false));
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeIsMemberOff USING ((((GLOBAL default::userCurrent).organization.id ?= .id) ?? false));
  };
  DROP GLOBAL default::apiUser;
  ALTER TYPE default::Primitive {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
      };
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING ((((GLOBAL default::userCurrent).organization ?= .organization) ?? false));
      ALTER ACCESS POLICY IAllowSuperAdminToSelectForAnalyticsAndUpdateForMigrations USING (((GLOBAL default::userCurrent).superAdmin ?? false));
  };
  ALTER TYPE activity::PrimitivePropertyChange {
      ALTER ACCESS POLICY IAllowSelectUpdateIfUserInSameOrganizationThanPrimitive USING ((((GLOBAL default::userCurrent).organization ?= .primitive.organization) ?? false));
  };
  ALTER TYPE activity::Activity {
      ALTER ACCESS POLICY IAllowSuperAdminToSelectForAnalytics USING (((GLOBAL default::userCurrent).superAdmin ?? false));
      ALTER LINK actor {
          SET default := (SELECT
              default::User
          FILTER
              (.id = (GLOBAL default::userCurrent).id)
          );
      };
      ALTER ACCESS POLICY IAllowUserToInsertItsActivityAndSelectItForDebouncing USING (((GLOBAL default::userCurrent).id ?= .actor.id));
  };
  ALTER TYPE default::PrimitiveProperty {
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING ((((GLOBAL default::userCurrent).organization ?= .organization) ?? false));
  };
  ALTER TYPE chat::Chat {
      ALTER ACCESS POLICY IAllowOnlyUserToAccessItsChats USING (NOT (((GLOBAL default::userCurrent).id ?= .createdBy.id)));
  };
  ALTER TYPE chat::Message {
      ALTER ACCESS POLICY IAllowOnlyUserToAccessItsMessages USING (NOT (((GLOBAL default::userCurrent).id ?= .chat.createdBy.id)));
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY IAllowServerToSelectInsertAndUpdateUsers USING (NOT (EXISTS (GLOBAL default::userCurrent)));
      ALTER ACCESS POLICY IAllowSuperAdminToSelectUserForAnalytics USING (((GLOBAL default::userCurrent).superAdmin ?? false));
      ALTER ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization USING ((((GLOBAL default::userCurrent).organization ?= .organization) ?? false));
      ALTER ACCESS POLICY IGiveFullReadWriteAccessToUserRegardingItsOwnData USING (((GLOBAL default::userCurrent).id ?= .id));
  };
  ALTER TYPE default::Invitation {
      ALTER ACCESS POLICY IAllowUserToSelectItsOwnInvitationIfItHasNotExpired USING ((((GLOBAL default::userCurrent).email ?= .email) AND (.expiresAt > std::datetime_of_statement())));
  };
  ALTER TYPE relation::Relation {
      ALTER ACCESS POLICY IAllowSuperAdminToSelectForAnalytics USING (((GLOBAL default::userCurrent).superAdmin ?? false));
  };
};
