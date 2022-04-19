import React from 'react'

export default function NavBar() {

  const logout = async e => {
    e.preventDefault();
    try {
      localStorage.removeItem("token");
    } catch (err) {
      console.error(err.message);
    }
  };

  return (
    <>
      <nav class="navbar navbar-dark bg-primary fixed-top">
        <div class="container-fluid">
          <div class="navbar-brand">TraceTheGather</div>
          
          <button onClick={e => logout(e)} className="btn"> Logout </button>
        </div>
        
      </nav>
    </>
  )
}
