CREATE MIGRATION m1bnmmaz7lgtpvgco5dyua6i6bcgfj7xr3l6u3fwev7fdexyhe65eq
    ONTO m122tp2pkmhjfu6apjabndrjtljowtj6agq6d6fj4e7ugv6d7kieoa
{
  ALTER GLOBAL default::userCurrent USING (SELECT
      default::User FILTER
          (((.id = GLOBAL default::currentUserId) ?? (.apiKey = GLOBAL default::apiKey)) AND NOT (EXISTS (.archivedAt)))
  LIMIT
      1
  );
};
