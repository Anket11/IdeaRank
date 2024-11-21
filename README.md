# **IdeaRank** 🎉  
_A smarter way to prioritize your ideas!_

## **Overview**  
We all have great ideas, but deciding which one to pursue can be challenging. Human brains struggle with assigning numerical values to abstract concepts, but we excel at comparing things side by side. Enter **IdeaRank**: a tool that leverages your comparative instincts to help you prioritize and rank your ideas effectively.

With **IdeaRank**, you can:  
- Quickly identify your best ideas.  
- Rank them in order of priority.  
- Focus on what truly matters.

---


## **Getting Started** 🚀  

Install ELM and Follow these steps to run IdeaRank locally:  

1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/your-repo/idearank.git
   
2. Build the JavaScript file using `elm make`:
    elm make --output js/idea-fight.js Main.elm

3. Open `index.html` in your browser.

---

## **How It Works** 🛠️  

1. **Input Your Ideas**: Start by entering a list of ideas you want to prioritize.  
2. **Comparison Mode**: IdeaRank randomly pairs your ideas and asks you to choose between them.  
3. **Dynamic Ranking**: Based on your selections, it builds a ranking using a **Partially Ordered Forest** algorithm.  
4. **Result**: Keep comparing until you’re satisfied with the order or stop after picking the top few ideas.  

---

## **The Algorithm: Partially Ordered Forests** 🌲  

The ranking system behind IdeaRank is powered by a clever algorithm inspired by a **partial merge sort**. Here’s how it works:  
- Each idea starts as an independent node in a forest (a collection of trees).  
- When you pick an idea over another, IdeaRank rearranges the forest to reflect that relationship.  
- Over time, the forest evolves into a prioritized order based on your comparisons.  

### **Performance**:  
- **Top Idea Selection**: Linear time complexity (O(n)).  
- **Full Ranking**: Efficient sorting in O(n log n).

---

## **Why Elm?** 💡  

**IdeaRank** is built using [Elm](https://elm-lang.org), a functional programming language tailored for web applications. Elm ensures:  
- **Error-Free Code**: With its robust type system, Elm eliminates runtime errors.  
- **Smooth User Experience**: Elm’s virtual DOM ensures fast and responsive updates.  
- **Maintainable Architecture**: Elm's **Model-Update-View (MUV)** pattern simplifies complex app logic.  

---



## *Credits and Contributions to the IdeaRank Project* 🙌  

### *1. Dhairya and Esha (Frontend & Elm Development)*  
•⁠  ⁠Designed and implemented the user interface using HTML and CSS.  
•⁠  ⁠Contributed to the Elm codebase, focusing on state management and UI integration.  
•⁠  ⁠Coordinated project tasks, ensuring timely progress
•⁠  ⁠Drafted parts of the ⁠ README.md ⁠, focusing on frontend documentation and setup instructions.  

### *2. Anket and Khashayar (Elm Development & Project Coordination)*  
•⁠  ⁠Authored and managed the core Elm application logic and Partial Forest Algorithm.  
•⁠  ⁠Set up and configured ⁠ elm.json ⁠, managing dependencies.  
•⁠  ⁠Handled responsive design and ensured cross-browser compatibility.  
•⁠  ⁠Drafted parts of the ⁠ README.md ⁠, focusing on backend integration and project usage.