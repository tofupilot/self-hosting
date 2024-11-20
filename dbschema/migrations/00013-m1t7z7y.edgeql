CREATE MIGRATION m1t7z7ykumkqgyysclmfznlwb646x2rnzv6ekcdubzidgh6zcgmo6a
    ONTO m1swgxcvedsq55p5gth7uhoxbgqy6wuygi5j3htfylygjtiskxzuca
{
  ALTER TYPE default::Primitive {
      CREATE LINK createdBy -> default::User {
          SET default := (SELECT
              default::User
          FILTER
              (.id = GLOBAL default::currentUserId)
          );
          SET readonly := true;
      };
  };
  ALTER TYPE default::Label {
      CREATE LINK createdBy -> default::User {
          SET default := (SELECT
              default::User
          FILTER
              (.id = GLOBAL default::currentUserId)
          );
          SET readonly := true;
      };
  };
  ALTER TYPE default::Status {
      CREATE LINK createdBy -> default::User {
          SET default := (SELECT
              default::User
          FILTER
              (.id = GLOBAL default::currentUserId)
          );
          SET readonly := true;
      };
  };
};
