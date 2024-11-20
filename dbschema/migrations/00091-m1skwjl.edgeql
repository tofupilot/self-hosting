CREATE MIGRATION m1skwjlpqbo3et44mmirqbufkq26xu5nbwjsf5bvjr5rwip55ndovq
    ONTO m1ncxqqee265ndejiczy5qtit66s35aja3kdn5hzis4vsknt4l2bva
{
  ALTER TYPE default::Project {
      CREATE MULTI LINK categories := (.<project[IS default::Category]);
  };
};
