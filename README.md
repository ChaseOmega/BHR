# BHR - (Working Title) - Spiritual Successor to Battle Hunter

Project Status:  Currently a Personal Project  (Actively being developed and refined in my spare time)

Project Overview:

BHR is a personal project to create a spiritual successor to the classic game "Battle Hunter."  This project is effectively a tile based RPG where players clash over control of various resources using clever customization and negotiation.

Planned features for first public test:
Turn based combat
Character customization
  In the form of skills,cards,equipment, and perks.
Player chats
NPCs
  Will use Dijkstra Maps for navigation, agents will proioritize targets based on various critera.

Implemented features so far:
Dijkstra Map pathfinding for AI agents. This same functionality is used for determining tiles that are within movement range and adapting to agents should be a smooth process.
Networking. Commands are all submitted to server and their effects are reflected in client application. Current system limits information given to players to reduce risk of cheating.
Placeholder UI: While not very refined, it works and allows for the processing of player input.
Character customization, currently stored locally and sent to server. Fully Server side implementation in the works.
  Within this characters currently can use Skills, perks, equipment and cards; however, they still need some work to be fully functioning models.


As a personal project, BHR is currently under active development and refinement.  While code quality is a continuous focus,  parts of the codebase are still undergoing cleanup and optimization.  This project represents a journy as I improve as a game developer.  I am actively working on improving code structure, adding comments, and enhancing overall maintainability as development progresses.

Feel free to explore the codebase.  While it's still a work in progress, you may find useful implementations of Dijkstra maps and a few other things.  If you have questions or need help understanding specific functionalities for your own projects, please don't hesitate to reach out – I'm happy to share my knowledge and assist where I can.

Chase Stump - chaseomega@gmail.com

---
I will be adding various aspects of this project to their own repos for easier implementation into other projects. These will be made public alongside this project.

Also keep in mind that most art assets are not my own and I do not claim ownership of them. These are placeholders.
