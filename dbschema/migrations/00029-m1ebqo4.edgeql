CREATE MIGRATION m1ebqo4k5yx43h3j5xkcohfrtyyhkqx2rfxcrw6kxn66xxtuy4nepa
    ONTO m1vtnxowui6kmwnpfq3y3r6fkb2ofabn3my3bg6xmmfnqdueke55aa
{
  ALTER TYPE default::User {
      ALTER LINK imageUploaded {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
};
