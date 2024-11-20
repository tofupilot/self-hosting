CREATE MIGRATION m1nlbw2nsbco3zvveqpibr5pq5jmuscdecamugbccrsvethafd2edq
    ONTO m15pz2zrsdgaqxxc77p3pvpsd7mdfwuxblihgyt73xvafsb2bfbojq
{
  ALTER TYPE default::Unit {
      CREATE LINK createdFrom: default::Action {
          ON SOURCE DELETE ALLOW;
          ON TARGET DELETE ALLOW;
      };
  };
};
