const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Rock = sequelize.define('Rock', {
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  type: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  geographicalPresence: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  physicalProperties: {
    type: DataTypes.JSON,
    defaultValue: {}
  },
  color: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  hardness: {
    type: DataTypes.JSON,
    defaultValue: {}
  },
  imageUrl: DataTypes.STRING,
  dangerLevel: DataTypes.STRING,
  geologicalProperties: DataTypes.TEXT,
  commonUses: DataTypes.TEXT,
  imageQuality: DataTypes.STRING,
  confidenceLevel: DataTypes.STRING,
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    }
  }
});

module.exports = Rock; 