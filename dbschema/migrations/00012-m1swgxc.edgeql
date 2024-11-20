CREATE MIGRATION m1swgxcvedsq55p5gth7uhoxbgqy6wuygi5j3htfylygjtiskxzuca
    ONTO m1ivhuqsrdgn6jpmrefd3w2ipl74i3u7ykjahvqnshotkt4rvzlp2a
{
  ALTER TYPE default::Project {
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
